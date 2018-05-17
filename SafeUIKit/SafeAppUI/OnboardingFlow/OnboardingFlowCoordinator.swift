//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import IdentityAccessApplication

final class OnboardingFlowCoordinator: FlowCoordinator {

    let masterPasswordFlowCoordinator = MasterPasswordFlowCoordinator()
    let setupSafeFlowCoordinator = SetupSafeFlowCoordinator()

    private var isUserRegistered: Bool {
        return ApplicationServiceRegistry.authenticationService.isUserRegistered
    }

    override func setUp() {
        super.setUp()
        if isUserRegistered {
            enterSetupSafeFlow()
        } else {
            push(StartViewController.create(delegate: self))
        }
    }

    private func enterSetupSafeFlow() {
        enter(flow: setupSafeFlowCoordinator) { [unowned self] in
            self.exitFlow()
        }
    }

}

extension OnboardingFlowCoordinator: StartViewControllerDelegate {

    func didStart() {
        enter(flow: masterPasswordFlowCoordinator) { [unowned self] in
            self.clearNavigationStack()
            self.enterSetupSafeFlow()
        }
    }

}
