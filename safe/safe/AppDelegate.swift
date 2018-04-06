//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Crashlytics
import Fabric
import UIKit
import IdentityAccessApplication

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var coordinator: AppFlowCoordinatorProtocol = AppFlowCoordinator()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])
        configureDependencyInjection()
        #if DEBUG
            TestSupport.shared.addResettable(Account.shared)
            TestSupport.shared.setUp()
        #endif
        createWindow()
        return true
    }

    func configureDependencyInjection() {
        ApplicationServiceRegistry.put(service: AuthenticationApplicationService(account: Account.shared),
                                       for: AuthenticationApplicationService.self)

        DomainRegistry.put(service: UserDefaultsService(), for: KeyValueStore.self)
        DomainRegistry.put(service: KeychainService(), for: SecureStore.self)
        DomainRegistry.put(service: BiometricService(), for: BiometricAuthenticationService.self)
        DomainRegistry.put(service: SystemClockService(), for: Clock.self)
        DomainRegistry.put(service: LogService.shared, for: Logger.self)
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
