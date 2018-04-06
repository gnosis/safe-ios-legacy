//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit

final class OnboardingFlowCoordinator: FlowCoordinator {

    let masterPasswordFlowCoordinator = MasterPasswordFlowCoordinator()
    let setupSafeFlowCoordinator = SetupSafeFlowCoordinator()

    init() {
        super.init()
        masterPasswordFlowCoordinator.completion = masterPasswordCompletion
    }

    private func masterPasswordCompletion() {
        let vc = setupSafeFlowCoordinator.startViewController(parent: rootVC)
        rootVC.setViewControllers([vc], animated: true)
    }

    override func flowStartController() -> UIViewController {
        return ApplicationServiceRegistry.authenticationService().isUserRegistered() ? 
            setupSafeFlowCoordinator.startViewController(parent: rootVC) :
            masterPasswordFlowCoordinator.startViewController(parent: rootVC)
    }

}
