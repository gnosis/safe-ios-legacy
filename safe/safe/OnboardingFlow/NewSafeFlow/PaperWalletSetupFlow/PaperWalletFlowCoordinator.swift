//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import IdentityAccessApplication
import IdentityAccessDomainModel

typealias PaperWalletSetupCompletion = () -> Void

final class PaperWalletFlowCoordinator: FlowCoordinator {

    private let completion: PaperWalletSetupCompletion?
    private let draftSafe: DraftSafe?

    init(draftSafe: DraftSafe?, completion: PaperWalletSetupCompletion? = nil) {
        self.draftSafe = draftSafe
        self.completion = completion
    }

    override func flowStartController() -> UIViewController {
        return SaveMnemonicViewController.create(words: draftSafe?.paperWalletMnemonicWords ?? [], delegate: self)
    }

}

extension PaperWalletFlowCoordinator: SaveMnemonicDelegate {

    func didPressContinue() {
        guard !draftSafe!.confirmedAddresses.contains(.paperWallet) else {
            completion?()
            return
        }
        let controller = ConfirmMnemonicViewController.create(
            delegate: self,
            words: draftSafe!.paperWalletMnemonicWords)
        rootVC.pushViewController(controller, animated: true)
    }

}

extension PaperWalletFlowCoordinator: ConfirmMnemonicDelegate {

    func didConfirm() {
        completion?()
    }

}
