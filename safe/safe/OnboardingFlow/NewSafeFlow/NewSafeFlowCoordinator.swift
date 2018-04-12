//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit
import IdentityAccessApplication

final class NewSafeFlowCoordinator: FlowCoordinator {

    private var identityService: IdentityApplicationService { return ApplicationServiceRegistry.identityService }
    let setupRecoveryFlowCoordinator = SetupRecoveryFlowCoordinator()

    override func flowStartController() -> UIViewController {
        if identityService.isRecoverySet {
            return PairWithChromeExtensionViewController()
        }
        return setupRecoveryFlowCoordinator.startViewController(parent: rootVC)
    }

}
