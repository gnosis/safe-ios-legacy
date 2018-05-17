//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication

typealias PaperWalletSetupCompletion = () -> Void

final class PaperWalletFlowCoordinator: FlowCoordinator {

    override func setUp() {
        super.setUp()
        push(SaveMnemonicViewController.create(delegate: self))
    }

}

extension PaperWalletFlowCoordinator: SaveMnemonicDelegate {

    func didPressContinue() {
        guard !ApplicationServiceRegistry.walletService.isOwnerExists(.paperWallet) else {
            exitFlow()
            return
        }
        let mnemonicController = navigationController.topViewController as! SaveMnemonicViewController
        push(ConfirmMnemonicViewController.create(delegate: self, account: mnemonicController.account))
    }

}

extension PaperWalletFlowCoordinator: ConfirmMnemonicDelegate {

    func didConfirm() {
        exitFlow()
    }

}
