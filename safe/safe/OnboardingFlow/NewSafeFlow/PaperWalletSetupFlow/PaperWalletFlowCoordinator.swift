//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import IdentityAccessApplication
import IdentityAccessDomainModel

typealias PaperWalletSetupCompletion = () -> Void

final class PaperWalletFlowCoordinator: FlowCoordinator {

    var completion: PaperWalletSetupCompletion?
    var draftSafe: DraftSafe?

    override func flowStartController() -> UIViewController {
        var words: [String] = []
        if let draftSafe = draftSafe { words = draftSafe.paperWalletMnemonicWords }
        return SaveMnemonicViewController.create(words: words, delegate: self)
    }

}

extension PaperWalletFlowCoordinator: SaveMnemonicDelegate {

    func didPressContinue() {
        let controller = ConfirmMnemonicViewController.create(delegate: self, words: draftSafe!.paperWalletMnemonicWords)
        rootVC.pushViewController(controller, animated: true)
    }

}

extension PaperWalletFlowCoordinator: ConfirmMnemonicDelegate {

    func didConfirm() {
        completion?()
    }

}
