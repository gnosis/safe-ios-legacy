//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit

class AppFlowCoordinator {

    let onboardingFlowCoordinator = OnboardingFlowCoordinator()

    func startViewController() -> UIViewController {
        return onboardingFlowCoordinator.startViewController()
    }

}
