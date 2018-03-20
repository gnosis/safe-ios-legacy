//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Crashlytics
import Fabric
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var coordinator: AppFlowCoordinatorProtocol = AppFlowCoordinator()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])
        #if DEBUG
            TestSupport.shared.addResettable(Account.shared)
            TestSupport.shared.setUp()
        #endif
        createWindow()
        return true
    }

    private func createWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = coordinator.startViewController()
        window?.makeKeyAndVisible()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        coordinator.appBecomesActive()
    }

}
