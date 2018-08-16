//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Crashlytics
import Fabric
import UIKit
import SafeAppUI
import IdentityAccessApplication
import IdentityAccessDomainModel
import IdentityAccessImplementations
import MultisigWalletApplication
import MultisigWalletDomainModel
import MultisigWalletImplementations
import Database
import Common
import CommonImplementations
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, Resettable {

    var window: UIWindow?
    lazy var coordinator = AppFlowCoordinator()
    var identityAccessDB: Database?
    var multisigWalletDB: Database?
    var secureStore: SecureStore?
    var appConfig: AppConfig!

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])

        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
        Messaging.messaging().shouldEstablishDirectChannel = true

        // https://firebase.google.com/docs/cloud-messaging/ios/client
        // for devices running iOS 10 and above, you must assign your delegate object to the UNUserNotificationCenter
        // object to receive display notifications, and the FIRMessaging object to receive data messages,
        // before your app finishes launching.
        UNUserNotificationCenter.current().delegate = self

        appConfig = try! AppConfig.loadFromBundle()!
        configureDependencyInjection()

        #if DEBUG
        TestSupport.shared.addResettable(self)
        TestSupport.shared.setUp()
        #endif

        createWindow()
        UIApplication.shared.applicationIconBadgeNumber = 0
        synchronise()
        return true
    }

    func configureDependencyInjection() {
        configureIdentityAccess()
        configureMultisigWallet()
        configureEthereum()
    }

    private func configureIdentityAccess() {
        IdentityAccessApplication.ApplicationServiceRegistry.put(service: AuthenticationApplicationService(),
                                                                 for: AuthenticationApplicationService.self)
        IdentityAccessApplication.ApplicationServiceRegistry.put(service: SystemClockService(), for: Clock.self)
        IdentityAccessApplication.ApplicationServiceRegistry.put(service: LogService.shared, for: Logger.self)
        IdentityAccessDomainModel.DomainRegistry.put(service: BiometricService(),
                                                     for: BiometricAuthenticationService.self)
        IdentityAccessDomainModel.DomainRegistry.put(service: SystemClockService(), for: Clock.self)
        let encryptionService = IdentityAccessImplementations.CommonCryptoEncryptionService()
        IdentityAccessDomainModel.DomainRegistry.put(service: encryptionService,
                                                     for: IdentityAccessDomainModel.EncryptionService.self)
        IdentityAccessDomainModel.DomainRegistry.put(service: IdentityService(), for: IdentityService.self)
        setUpIdentityAccessDatabase()
    }

    private func configureMultisigWallet() {
        MultisigWalletApplication.ApplicationServiceRegistry.put(service: WalletApplicationService(),
                                                                 for: WalletApplicationService.self)
        MultisigWalletApplication.ApplicationServiceRegistry.put(service: LogService.shared, for: Logger.self)
        let notificationService = HTTPNotificationService(url: appConfig.notificationServiceURL,
                                                          logger: LogService.shared)
        MultisigWalletDomainModel.DomainRegistry.put(service: notificationService, for: NotificationDomainService.self)
        MultisigWalletDomainModel.DomainRegistry.put(service: PushTokensService(), for: PushTokensDomainService.self)
        MultisigWalletDomainModel.DomainRegistry.put(service: SynchronisationService(),
                                                     for: SynchronisationDomainService.self)
        MultisigWalletDomainModel.DomainRegistry.put(service: EventPublisher(), for: EventPublisher.self)
        setUpMultisigDatabase()
    }

    private func configureEthereum() {
        MultisigWalletApplication.ApplicationServiceRegistry.put(service: EthereumApplicationService(),
                                                                 for: EthereumApplicationService.self)
        MultisigWalletApplication.ApplicationServiceRegistry.put(service: LogService.shared, for: Logger.self)

        let chainId = EIP155ChainId(rawValue: appConfig.encryptionServiceChainId)!
        let encryptionService = MultisigWalletImplementations.EncryptionService(chainId: chainId)
        MultisigWalletDomainModel.DomainRegistry.put(service: encryptionService,
                                                     for: MultisigWalletDomainModel.EncryptionDomainService.self)
        let relayService = GnosisTransactionRelayService(url: appConfig.relayServiceURL, logger: LogService.shared)
        MultisigWalletDomainModel.DomainRegistry.put(service: relayService, for: TransactionRelayDomainService.self)

        secureStore = KeychainService(identifier: "pm.gnosis.safe")
        MultisigWalletDomainModel.DomainRegistry.put(service:
            SecureExternallyOwnedAccountRepository(store: secureStore!),
                                                     for: ExternallyOwnedAccountRepository.self)

        let nodeService = InfuraEthereumNodeService(url: appConfig.nodeServiceConfig.url,
                                                    chainId: appConfig.nodeServiceConfig.chainId)
        MultisigWalletDomainModel.DomainRegistry.put(service: nodeService, for: EthereumNodeDomainService.self)
    }

    private func setUpIdentityAccessDatabase() {
        do {
            let db = SQLiteDatabase(name: "IdentityAccess",
                                    fileManager: FileManager.default,
                                    sqlite: CSQLite3(),
                                    bundleId: Bundle.main.bundleIdentifier ?? "pm.gnosis.safe")
            identityAccessDB = db
            let userRepo = DBSingleUserRepository(db: db)
            let gatekeeperRepo = DBSingleGatekeeperRepository(db: db)
            IdentityAccessDomainModel.DomainRegistry.put(service: userRepo, for: SingleUserRepository.self)
            IdentityAccessDomainModel.DomainRegistry.put(service: gatekeeperRepo, for: SingleGatekeeperRepository.self)

            if !db.exists {
                try db.create()
                try userRepo.setUp()
                try gatekeeperRepo.setUp()

                try ApplicationServiceRegistry.authenticationService
                    .createAuthenticationPolicy(sessionDuration: 60,
                                                maxPasswordAttempts: 3,
                                                blockedPeriodDuration: 15)
            }
        } catch let e {
            ErrorHandler.showFatalError(log: "Failed to set up identity access database", error: e)
        }
    }

    private func setUpMultisigDatabase() {
        do {
            let db = SQLiteDatabase(name: "MultisigWallet",
                                    fileManager: FileManager.default,
                                    sqlite: CSQLite3(),
                                    bundleId: Bundle.main.bundleIdentifier ?? "pm.gnosis.safe")
            multisigWalletDB = db
            let walletRepo = DBWalletRepository(db: db)
            let portfolioRepo = DBSinglePortfolioRepository(db: db)
            let accountRepo = DBAccountRepository(db: db)
            let transactionRepo = DBTransactionRepository(db: db)
            MultisigWalletDomainModel.DomainRegistry.put(service: walletRepo, for: WalletRepository.self)
            MultisigWalletDomainModel.DomainRegistry.put(service: portfolioRepo, for: SinglePortfolioRepository.self)
            MultisigWalletDomainModel.DomainRegistry.put(service: accountRepo, for: AccountRepository.self)
            MultisigWalletDomainModel.DomainRegistry.put(service: transactionRepo, for: TransactionRepository.self)

            if !db.exists {
                try db.create()
            }
            portfolioRepo.setUp()
            walletRepo.setUp()
            accountRepo.setUp()
            transactionRepo.setUp()
        } catch let e {
            ErrorHandler.showFatalError(log: "Failed to set up multisig database", error: e)
        }
    }

    private func createWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        coordinator.setUp()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        coordinator.appEntersForeground()
        UIApplication.shared.applicationIconBadgeNumber = 0
        synchronise()
    }

    private func synchronise() {
        MultisigWalletDomainModel.DomainRegistry.syncService.sync()
    }

    func resetAll() {
        if let db = identityAccessDB {
            try? db.destroy()
            setUpIdentityAccessDatabase()
        }
        if let db = multisigWalletDB {
            try? db.destroy()
            setUpMultisigDatabase()
        }
        if let store = secureStore {
            try? store.destroy()
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        LogService.shared.error("Failed to registed to remote notifications", error: error)
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        LogService.shared.debug("willPresent notification with userInfo: \(userInfo)")
        UIApplication.shared.applicationIconBadgeNumber = 0
        coordinator.receive(message: userInfo)
        completionHandler([])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        LogService.shared.debug("didReceive notification with userInfo: \(userInfo)")
        coordinator.receive(message: userInfo)
        completionHandler()
    }

}

extension AppDelegate: MessagingDelegate {

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        LogService.shared.debug("Firebase registration token: \(fcmToken)")
    }

    // This is called if APNS messaging is disabled and the app is in foreground
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        LogService.shared.debug("Received data message: \(remoteMessage.appData)")
        coordinator.receive(message: remoteMessage.appData)
    }

}
