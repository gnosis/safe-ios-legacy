//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit

final class OnboardingFlowCoordinator {

    let masterPasswordFlowCoordinator = MasterPasswordFlowCoordinator()
    let setupSafeFlowCoordinator = SetupSafeFlowCoordinator()

    func startViewController() -> UIViewController {
        return ApplicationServiceRegistry.authenticationService().isUserRegistered() ?
            setupSafeFlowCoordinator.startViewController() :
            masterPasswordFlowCoordinator.startViewController()
    }

}
