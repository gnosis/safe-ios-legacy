//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit

class AppFlowCoordinator {

    let onboardingFlowCoordinator = OnboardingFlowCoordinator()

    var account: AccountProtocol = Account.shared

    func startViewController() -> UIViewController {
        return account.hasMasterPassword ? unlockController() : onboardingFlowCoordinator.startViewController()
    }

    func unlockController() -> UIViewController {
        return UIViewController()
    }

}
