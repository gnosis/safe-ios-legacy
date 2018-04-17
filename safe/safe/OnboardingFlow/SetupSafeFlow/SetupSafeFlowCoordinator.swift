//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

final class SetupSafeFlowCoordinator: FlowCoordinator {

    private let newSafeFlowCoordinator = NewSafeFlowCoordinator()

    override func flowStartController() -> UIViewController {
        return SetupSafeOptionsViewController.create(delegate: self)
    }

}

extension SetupSafeFlowCoordinator: SetupSafeOptionsDelegate {

    func didSelectNewSafe() {        
        let startVC = newSafeFlowCoordinator.startViewController(parent: rootVC)
        rootVC.pushViewController(startVC, animated: true)
    }

}
