//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import IdentityAccessApplication

final class OnboardingFlowCoordinator: FlowCoordinator {

    let masterPasswordFlowCoordinator = MasterPasswordFlowCoordinator()
    let setupSafeFlowCoordinator = SetupSafeFlowCoordinator()

    override init() {
        super.init()
        masterPasswordFlowCoordinator.completion = masterPasswordCompletion
    }

    private func masterPasswordCompletion() {
        let vc = setupSafeFlowCoordinator.startViewController(parent: rootVC)
        rootVC.setViewControllers([vc], animated: true)
    }

    override func flowStartController() -> UIViewController {
        return ApplicationServiceRegistry.authenticationService.isUserRegistered ?
            setupSafeFlowCoordinator.startViewController(parent: rootVC) :
            masterPasswordFlowCoordinator.startViewController(parent: rootVC)
    }

}
