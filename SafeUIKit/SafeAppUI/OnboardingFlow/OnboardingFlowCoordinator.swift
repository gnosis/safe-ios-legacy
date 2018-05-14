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
            transition(to: setupSafeFlowCoordinator)
        } else {
            transition(to: masterPasswordFlowCoordinator) { [unowned self] in
                self.clearNavigationStack()
                self.transition(to: self.setupSafeFlowCoordinator)
            }
        }
    }

}
