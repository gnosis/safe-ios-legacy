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
            enter(flow: setupSafeFlowCoordinator)
        } else {
            push(StartViewController.create(delegate: self))
        }
    }

}

extension OnboardingFlowCoordinator: StartViewControllerDelegate {

    func didStart() {
        enter(flow: masterPasswordFlowCoordinator) { [unowned self] in
            self.clearNavigationStack()
            self.enter(flow: self.setupSafeFlowCoordinator)
        }
    }

}
