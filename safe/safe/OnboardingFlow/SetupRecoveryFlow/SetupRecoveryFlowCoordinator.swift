//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

final class SetupRecoveryFlowCoordinator: FlowCoordinator {

    override func flowStartController() -> UIViewController {
        return RecoveryOptionsViewController.create(delegate: self)
    }

}

extension SetupRecoveryFlowCoordinator: SetupRecoveryOptionDelegate {

    func didSelectMnemonicRecovery() {}

}
