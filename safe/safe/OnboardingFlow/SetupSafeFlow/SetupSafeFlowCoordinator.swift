//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit
import IdentityAccessApplication

final class SetupSafeFlowCoordinator: FlowCoordinator {

    private var identityService: IdentityApplicationService { return ApplicationServiceRegistry.identityService }
    private let newSafeFlowCoordinator = NewSafeFlowCoordinator()

    override func flowStartController() -> UIViewController {
        return SetupSafeOptionsViewController.create(delegate: self)
    }

}

extension SetupSafeFlowCoordinator: SetupSafeOptionsDelegate {

    func didSelectNewSafe() {
        guard (try? identityService.getOrCreateEOA()) != nil else { return }
        let startVC = newSafeFlowCoordinator.startViewController(parent: rootVC)
        rootVC.pushViewController(startVC, animated: true)
    }

}
