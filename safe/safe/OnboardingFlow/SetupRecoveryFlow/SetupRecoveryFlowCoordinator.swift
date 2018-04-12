//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

final class SetupRecoveryFlowCoordinator: FlowCoordinator {

    let recoveryWithMnemonicFlowCoordinator = RecoveryWithMnemonicFlowCoordinator()

    override func flowStartController() -> UIViewController {
        return SelectRecoveryOptionViewController.create(delegate: self)
    }

}

extension SetupRecoveryFlowCoordinator: SetupRecoveryOptionDelegate {

    func didSelectMnemonicRecovery() {
        let controller = recoveryWithMnemonicFlowCoordinator.startViewController(parent: rootVC)
        rootVC.pushViewController(controller, animated: true)
    }

}
