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
import Database

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var coordinator: AppFlowCoordinatorProtocol = AppFlowCoordinator()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])
        configureDependencyInjection()
        #if DEBUG
            TestSupport.shared.addResettable(ApplicationServiceRegistry.authenticationService)
            TestSupport.shared.setUp()
        #endif
        createWindow()
        return true
    }

    func configureDependencyInjection() {
        MultisigWalletApplication.ApplicationServiceRegistry.put(service: WalletApplicationService(),
                                                                 for: WalletApplicationService.self)
        ApplicationServiceRegistry.put(service: AuthenticationApplicationService(),
                                       for: AuthenticationApplicationService.self)
        ApplicationServiceRegistry.put(service: IdentityApplicationService(), for: IdentityApplicationService.self)
        ApplicationServiceRegistry.put(service: SystemClockService(), for: Clock.self)
        ApplicationServiceRegistry.put(service: LogService.shared, for: Logger.self)
        DomainRegistry.put(service: UserDefaultsService(), for: KeyValueStore.self)
        DomainRegistry.put(service: KeychainService(), for: SecureStore.self)
        DomainRegistry.put(service: BiometricService(), for: BiometricAuthenticationService.self)
        DomainRegistry.put(service: SystemClockService(), for: Clock.self)
        DomainRegistry.put(service: EncryptionService(), for: EncryptionServiceProtocol.self)
        DomainRegistry.put(service: IdentityService(), for: IdentityService.self)
        do {
            let db = SQLiteDatabase(name: "IdentityAccess",
                                    fileManager: FileManager.default,
                                    sqlite: CSQLite3(),
                                    bundleId: Bundle.main.bundleIdentifier ?? "pm.gnosis.safe")
            let userRepo = DBSingleUserRepository(db: db)
            let gatekeeperRepo = DBSingleGatekeeperRepository(db: db)
            DomainRegistry.put(service: userRepo, for: SingleUserRepository.self)
            DomainRegistry.put(service: gatekeeperRepo, for: SingleGatekeeperRepository.self)

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
            FatalErrorHandler.showFatalError(log: "Failed to setup authentication policy", error: e)
        }
    }

    private func createWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = coordinator.startViewController()
        window?.makeKeyAndVisible()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        coordinator.appEntersForeground()
    }

}

extension AuthenticationApplicationService: Resettable {

    func resetAll() {
        try? reset()
    }

}
