//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit

final class SetupSafeFlowCoordinator: FlowCoordinator {

    override func flowStartController() -> UIViewController {
        return SetupSafeOptionsViewController.create(delegate: self)
    }

}

extension SetupSafeFlowCoordinator: SetupSafeOptionsDelegate {

    func didSelectNewSafe() {
        let newSafeFlowCoordinator = NewSafeFlowCoordinator()
        let pairVC = newSafeFlowCoordinator.startViewController(parent: rootVC)
        rootVC.pushViewController(pairVC, animated: true)
    }

}
