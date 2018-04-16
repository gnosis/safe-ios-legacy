//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import IdentityAccessApplication

final class NewSafeFlowCoordinator: FlowCoordinator {

    private var identityService: IdentityApplicationService { return ApplicationServiceRegistry.identityService }
    let setupRecoveryFlowCoordinator = SetupRecoveryFlowCoordinator()

    override func flowStartController() -> UIViewController {
        return setupRecoveryFlowCoordinator.startViewController(parent: rootVC)
    }

}
