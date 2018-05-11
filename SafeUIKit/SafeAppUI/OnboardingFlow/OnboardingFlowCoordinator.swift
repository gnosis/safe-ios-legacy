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
        // TODO: if user registered
        //      if not selected any safe - show setup screen
        //      else if selected is restore - show restore flow flow
        //      else if selected is new - show new safe flow
        // else - show user registration flow
        return ApplicationServiceRegistry.authenticationService.isUserRegistered ?
            setupSafeFlowCoordinator.startViewController(parent: rootVC) :
            masterPasswordFlowCoordinator.startViewController(parent: rootVC)
    }

}
