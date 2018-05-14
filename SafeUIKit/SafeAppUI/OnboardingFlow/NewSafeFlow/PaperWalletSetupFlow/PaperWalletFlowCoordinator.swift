//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import IdentityAccessApplication

typealias PaperWalletSetupCompletion = () -> Void

final class PaperWalletFlowCoordinator: FlowCoordinator {

    private let draftSafe: DraftSafe?

    init(draftSafe: DraftSafe?) {
        self.draftSafe = draftSafe
    }

    override func setUp() {
        super.setUp()
        let words = draftSafe?.paperWalletMnemonicWords ?? []
        let controller = SaveMnemonicViewController.create(words: words, delegate: self)
        pushController(controller)
    }

}

extension PaperWalletFlowCoordinator: SaveMnemonicDelegate {

    func didPressContinue() {
        guard !draftSafe!.confirmedAddresses.contains(.paperWallet) else {
            exitFlow()
            return
        }
        let controller = ConfirmMnemonicViewController.create(
            delegate: self,
            words: draftSafe!.paperWalletMnemonicWords)
        pushController(controller)
    }

}

extension PaperWalletFlowCoordinator: ConfirmMnemonicDelegate {

    func didConfirm() {
        exitFlow()
    }

}
