//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit

class AppFlowCoordinator {

    let onboardingFlowCoordinator = OnboardingFlowCoordinator()

    func createWindow() -> UIWindow {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = onboardingFlowCoordinator.startViewController()
        return window
    }

}
