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

    func didPressContinue(mnemonicWords: [String]) {
        let controller = ConfirmMnemonicViewController.create(delegate: self, words: mnemonicWords)
        rootVC.pushViewController(controller, animated: true)
    }

}

extension RecoveryWithMnemonicFlowCoordinator: ConfirmMnemonicDelegate {

    func didConfirm() {}

}
