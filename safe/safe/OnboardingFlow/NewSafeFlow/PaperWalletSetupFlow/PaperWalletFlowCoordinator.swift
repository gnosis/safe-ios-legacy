//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

typealias PaperWalletSetupCompletion = () -> Void

final class PaperWalletFlowCoordinator: FlowCoordinator {

    var completion: PaperWalletSetupCompletion?

    override func flowStartController() -> UIViewController {
        return SaveMnemonicViewController.create(delegate: self)
    }

}

extension PaperWalletFlowCoordinator: SaveMnemonicDelegate {

    func didPressContinue(mnemonicWords: [String]) {
        let controller = ConfirmMnemonicViewController.create(delegate: self, words: mnemonicWords)
        rootVC.pushViewController(controller, animated: true)
    }

}

extension PaperWalletFlowCoordinator: ConfirmMnemonicDelegate {

    func didConfirm() {
        completion?()
    }

}
