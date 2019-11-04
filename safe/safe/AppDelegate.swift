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
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, Resettable {

    var window: UIWindow?
    lazy var coordinator = MainFlowCoordinator.shared
    var identityAccessDB: Database?
    var multisigWalletDB: Database?
    var secureStore: SecureStore?
    var appConfig: AppConfig!
    let filesystemGuard = UIKitFileSystemGuard()

    let defaultBundleIdentifier = "io.gnosis.safe" // DO NOT CHANGE BECAUSE DEFAULT DATABASE LOCATION MIGHT CHANGE

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])

        FirebaseApp.configure()
        Messaging.messaging().delegate = self

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
        cleanUp()
        sync()

        #if DEBUG
        NSSetUncaughtExceptionHandler { exc in
            print(exc)
            print(exc.callStackSymbols.joined(separator: "\n"))
        }
        #endif

        return true
    }

    func configureDependencyInjection() {
        configureFeatureFlags()
        IdentityAccessConfigurator.configure(with: self)
        MultisigWalletConfigurator.configure(with: self)
        #if DEBUG
        Tracker.shared.append(handler: ConsoleTracker())
        #endif
        Tracker.shared.append(handler: FirebaseTrackingHandler())
        Tracker.shared.append(handler: CrashlyticsTrackingHandler())
    }

    func configureFeatureFlags() {
        if let flags = appConfig.featureFlags {
            FeatureFlagSettings.instance = FeatureFlagSettings(flags: flags)
        }
    }

    private func createWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        coordinator.crashlytics = Crashlytics.sharedInstance()
        coordinator.setUp()
    }

    func sync() {
        DispatchQueue.global.async {
            DomainRegistry.syncService.syncTokensAndAccountsOnce()
            DomainRegistry.syncService.syncWalletConnectSessions()
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        coordinator.appEntersForeground()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        DomainRegistry.syncService.startSyncLoop()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        coordinator.appEnteredBackground()
        DomainRegistry.syncService.stopSyncLoop()
    }

    private func cleanUp() {
        DispatchQueue.global().async {
            DomainRegistry.transactionService.cleanUpStaleTransactions()
            ApplicationServiceRegistry.walletService.cleanUpAddressBook()
        }
    }

    func resetAll() {
        if let db = identityAccessDB {
            try? db.destroy()
            IdentityAccessConfigurator.setUpIdentityAccessDatabase(with: self)
        }
        if let db = multisigWalletDB {
            try? db.destroy()
            MultisigWalletConfigurator.setUpMultisigDatabase(with: self)
        }
        if let store = secureStore {
            try? store.destroy()
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        LogService.shared.error("Failed to registed to remote notifications \(error)")
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        LogService.shared.debug("Received deep link URL: \(url), options: \(options)")
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true) else {
            LogService.shared.error("Malformed deep link URL: \(url), options: \(options)")
            return false
        }
        components.scheme = "wc"
        let walletConnectURL = components.url!
        coordinator.receive(url: walletConnectURL)
        return true
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

    // This is called on every app restart.
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        LogService.shared.debug("Firebase registration token: \(fcmToken)")
        coordinator.updatePushToken(fcmToken)
    }

}
