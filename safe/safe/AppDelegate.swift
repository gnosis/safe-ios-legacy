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
import EthereumApplication
import Database
import Common
import CommonImplementations

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var coordinator = AppFlowCoordinator()

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
        EthereumApplication.ApplicationServiceRegistry.put(service: EthereumApplicationService(),
                                                           for: EthereumApplicationService.self)
        IdentityAccessApplication.ApplicationServiceRegistry.put(service: AuthenticationApplicationService(),
                                                                 for: AuthenticationApplicationService.self)
        IdentityAccessApplication.ApplicationServiceRegistry.put(service: IdentityApplicationService(),
                                                                 for: IdentityApplicationService.self)
        IdentityAccessApplication.ApplicationServiceRegistry.put(service: SystemClockService(), for: Clock.self)
        IdentityAccessApplication.ApplicationServiceRegistry.put(service: LogService.shared, for: Logger.self)
        IdentityAccessDomainModel.DomainRegistry.put(service: UserDefaultsService(), for: KeyValueStore.self)
        IdentityAccessDomainModel.DomainRegistry.put(service: KeychainService(), for: SecureStore.self)
        IdentityAccessDomainModel.DomainRegistry.put(service: BiometricService(),
                                                     for: BiometricAuthenticationService.self)
        IdentityAccessDomainModel.DomainRegistry.put(service: SystemClockService(), for: Clock.self)
        IdentityAccessDomainModel.DomainRegistry.put(service: EncryptionService(), for: EncryptionServiceProtocol.self)
        IdentityAccessDomainModel.DomainRegistry.put(service: IdentityService(), for: IdentityService.self)
        do {
            let db = SQLiteDatabase(name: "IdentityAccess",
                                    fileManager: FileManager.default,
                                    sqlite: CSQLite3(),
                                    bundleId: Bundle.main.bundleIdentifier ?? "pm.gnosis.safe")
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
        do {
            let db = SQLiteDatabase(name: "MultisigWallet",
                                    fileManager: FileManager.default,
                                    sqlite: CSQLite3(),
                                    bundleId: Bundle.main.bundleIdentifier ?? "pm.gnosis.safe")
            let walletRepo = DBWalletRepository(db: db)
            let portfolioRepo = DBSinglePortfolioRepository(db: db)
            let accountRepo = DBAccountRepository(db: db)
            MultisigWalletDomainModel.DomainRegistry.put(service: walletRepo, for: WalletRepository.self)
            MultisigWalletDomainModel.DomainRegistry.put(service: portfolioRepo, for: SinglePortfolioRepository.self)
            MultisigWalletDomainModel.DomainRegistry.put(service: accountRepo, for: AccountRepository.self)

            if !db.exists {
                try db.create()
                try portfolioRepo.setUp()
                try walletRepo.setUp()
                try accountRepo.setUp()
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

}

extension AuthenticationApplicationService: Resettable {

    func resetAll() {
        try? reset()
    }

}
