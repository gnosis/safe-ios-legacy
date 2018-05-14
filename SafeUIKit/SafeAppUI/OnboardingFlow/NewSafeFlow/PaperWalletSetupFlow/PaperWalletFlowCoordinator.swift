//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import IdentityAccessApplication

typealias PaperWalletSetupCompletion = () -> Void

final class PaperWalletFlowCoordinator: FlowCoordinator {

    private let draftSafe: DraftSafe?

    init(draftSafe: DraftSafe?, rootViewController: UIViewController? = nil) {
        self.draftSafe = draftSafe
        super.init(rootViewController: rootViewController)
    }

    override func setUp() {
        super.setUp()
        let words = draftSafe?.paperWalletMnemonicWords ?? []
        pushController(SaveMnemonicViewController.create(words: words, delegate: self))
    }

}

extension PaperWalletFlowCoordinator: SaveMnemonicDelegate {

    func didPressContinue() {
        guard !draftSafe!.confirmedAddresses.contains(.paperWallet) else {
            exitFlow()
            return
        }
        let words = draftSafe!.paperWalletMnemonicWords
        pushController(ConfirmMnemonicViewController.create(delegate: self, words: words))
    }

}

extension PaperWalletFlowCoordinator: ConfirmMnemonicDelegate {

    func didConfirm() {
        exitFlow()
    }

}
