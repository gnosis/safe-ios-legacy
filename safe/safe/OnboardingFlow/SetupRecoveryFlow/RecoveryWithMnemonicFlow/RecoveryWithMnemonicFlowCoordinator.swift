//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

final class RecoveryWithMnemonicFlowCoordinator: FlowCoordinator {

    override func flowStartController() -> UIViewController {
        return SaveMnemonicViewController.create(delegate: self)
    }

}

extension RecoveryWithMnemonicFlowCoordinator: SaveMnemonicDelegate {

    func didPressContinue() {
        let controller = ConfirmMnemonicViewController()
        rootVC.pushViewController(controller, animated: true)
    }

}
