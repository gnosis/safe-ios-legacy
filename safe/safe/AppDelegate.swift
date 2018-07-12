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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, Resettable {

    var window: UIWindow?
    lazy var coordinator = AppFlowCoordinator()
    var identityAccessDB: Database?
    var multisigWalletDB: Database?
    var secureStore: SecureStore?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])
        configureDependencyInjection()
        #if DEBUG
        TestSupport.shared.addResettable(self)
        TestSupport.shared.setUp()
        #endif
        createWindow()
        return true
    }

    func configureDependencyInjection() {
        configureIdentityAccess()
        configureMultisigWallet()
        configureEthereum()
        connectMultisigWalletWithEthereum()
    }

    private func configureIdentityAccess() {
        IdentityAccessApplication.ApplicationServiceRegistry.put(service: AuthenticationApplicationService(),
                                                                 for: AuthenticationApplicationService.self)
        IdentityAccessApplication.ApplicationServiceRegistry.put(service: SystemClockService(), for: Clock.self)
        IdentityAccessApplication.ApplicationServiceRegistry.put(service: LogService.shared, for: Logger.self)
        IdentityAccessDomainModel.DomainRegistry.put(service: BiometricService(),
                                                     for: BiometricAuthenticationService.self)
        IdentityAccessDomainModel.DomainRegistry.put(service: SystemClockService(), for: Clock.self)
        let encryptionService = IdentityAccessImplementations.EthereumKitEncryptionService()
        IdentityAccessDomainModel.DomainRegistry.put(service: encryptionService,
                                                     for: IdentityAccessDomainModel.EncryptionService.self)
        IdentityAccessDomainModel.DomainRegistry.put(service: IdentityService(), for: IdentityService.self)
        setUpIdentityAccessDatabase()
    }

    private func configureMultisigWallet() {
        MultisigWalletApplication.ApplicationServiceRegistry.put(service: WalletApplicationService(),
                                                                 for: WalletApplicationService.self)
        MultisigWalletApplication.ApplicationServiceRegistry.put(service: LogService.shared, for: Logger.self)
        MultisigWalletDomainModel.DomainRegistry.put(
            service: HTTPNotificationService(), for: NotificationDomainService.self)
        setUpMultisigDatabase()
    }

    private func configureEthereum() {
        MultisigWalletApplication.ApplicationServiceRegistry.put(service: EthereumApplicationService(),
                                                                 for: EthereumApplicationService.self)
        MultisigWalletApplication.ApplicationServiceRegistry.put(service: LogService.shared, for: Logger.self)
        MultisigWalletDomainModel.DomainRegistry.put(service: MultisigWalletImplementations.EncryptionService(),
                                                     for: MultisigWalletDomainModel.EncryptionDomainService.self)
        MultisigWalletDomainModel.DomainRegistry.put(service: GnosisTransactionRelayService(),
                                                     for: TransactionRelayDomainService.self)
        secureStore = KeychainService(identifier: "pm.gnosis.safe")
        MultisigWalletDomainModel.DomainRegistry.put(service:
            SecureExternallyOwnedAccountRepository(store: secureStore!),
                                                     for: ExternallyOwnedAccountRepository.self)
        MultisigWalletDomainModel.DomainRegistry.put(service: InfuraEthereumNodeService(),
                                                     for: EthereumNodeDomainService.self)
    }

    private func connectMultisigWalletWithEthereum() {
        let service = MultisigWalletApplication.ApplicationServiceRegistry.ethereumService
        MultisigWalletDomainModel.DomainRegistry.put(service: service, for: BlockchainDomainService.self)
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
            MultisigWalletDomainModel.DomainRegistry.put(service: walletRepo, for: WalletRepository.self)
            MultisigWalletDomainModel.DomainRegistry.put(service: portfolioRepo, for: SinglePortfolioRepository.self)
            MultisigWalletDomainModel.DomainRegistry.put(service: accountRepo, for: AccountRepository.self)

            if !db.exists {
                try db.create()
                portfolioRepo.setUp()
                walletRepo.setUp()
                accountRepo.setUp()
            }
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

}
