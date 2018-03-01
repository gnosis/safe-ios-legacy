//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit

class OnboardingFlowCoordinator {

    let masterPasswordFlowCoordinator = MasterPasswordFlowCoordinator()

    func startViewController() -> UIViewController {
        return masterPasswordFlowCoordinator.startViewController()
    }

}
