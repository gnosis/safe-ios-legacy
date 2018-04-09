//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit
import IdentityAccessApplication

final class SetupSafeFlowCoordinator: FlowCoordinator {

    private var identityService: IdentityApplicationService { return ApplicationServiceRegistry.identityService }

    override func flowStartController() -> UIViewController {
        return SetupSafeOptionsViewController.create(delegate: self)
    }

}

extension SetupSafeFlowCoordinator: SetupSafeOptionsDelegate {

    func didSelectNewSafe() {
        do {
            try identityService.getOrCreateEOA()
        } catch let e {
            // TODO: handle
        }
        let newSafeFlowCoordinator = NewSafeFlowCoordinator()
        let pairVC = newSafeFlowCoordinator.startViewController(parent: rootVC)
        rootVC.pushViewController(pairVC, animated: true)
    }

}
