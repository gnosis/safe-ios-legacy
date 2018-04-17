//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import IdentityAccessApplication
import IdentityAccessDomainModel

typealias PaperWalletSetupCompletion = () -> Void

final class PaperWalletFlowCoordinator: FlowCoordinator {

    var completion: PaperWalletSetupCompletion?

    private var identityService: IdentityApplicationService { return ApplicationServiceRegistry.identityService }
    private var logger: Logger { return DomainRegistry.logger }

    override func flowStartController() -> UIViewController {
        var words: [String] = []
        do {
            let draftSafe = try identityService.getOrCreateDraftSafe()
            words = draftSafe.paperWalletMnemonicWords
        } catch let e {
            logger.error("Error in getting EOA", error: e, file: #file, line: #line, function: #function)
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
