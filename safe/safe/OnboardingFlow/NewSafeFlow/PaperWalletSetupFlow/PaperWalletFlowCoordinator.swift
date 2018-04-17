//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import IdentityAccessApplication

typealias PaperWalletSetupCompletion = () -> Void

final class PaperWalletFlowCoordinator: FlowCoordinator {

    var completion: PaperWalletSetupCompletion?

    private var identityService: IdentityApplicationService { return ApplicationServiceRegistry.identityService }

    override func flowStartController() -> UIViewController {
        var words: [String] = []
        if let eoa = try? identityService.getOrCreateEOA() {
            words = eoa.mnemonic.words
        } else {
            // TODO: log
        }
        return SaveMnemonicViewController.create(words: words, delegate: self)
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
