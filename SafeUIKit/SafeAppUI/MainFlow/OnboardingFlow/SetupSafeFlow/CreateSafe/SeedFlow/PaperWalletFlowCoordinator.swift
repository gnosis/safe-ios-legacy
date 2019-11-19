//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication

typealias PaperWalletSetupCompletion = () -> Void

final class PaperWalletFlowCoordinator: FlowCoordinator {

    override func setUp() {
        super.setUp()
        push(ShowSeedViewController.create(delegate: self))
    }

}

extension PaperWalletFlowCoordinator: ShowSeedViewControllerDelegate {

    func showSeedViewControllerDidPressContinue(_ controller: ShowSeedViewController) {
        guard !ApplicationServiceRegistry.walletService.isOwnerExists(.paperWallet) else {
            exitFlow()
            return
        }
        push(ConfirmMnemonicViewController.create(delegate: self, account: controller.account!))
    }

}

extension PaperWalletFlowCoordinator: ConfirmMnemonicDelegate {

    func confirmMnemonicViewControllerDidConfirm(_ vc: ConfirmMnemonicViewController) {
        exitFlow()
    }

}
