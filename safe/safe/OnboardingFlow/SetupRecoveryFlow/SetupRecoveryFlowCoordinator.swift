//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit

final class SetupRecoveryFlowCoordinator: FlowCoordinator {

    override func flowStartController() -> UIViewController {
        return SelectRecoveryOptionViewController.create(delegate: self)
    }

}

extension SetupRecoveryFlowCoordinator: SetupRecoveryOptionDelegate {

    func didSelectMnemonicRecovery() {}

}
