//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication

class ReplaceBrowserExtensionFlowCoordinator: FlowCoordinator {

    weak var introVC: RBEIntroViewController?
    var transactionID: RBETransactionID!
    fileprivate var applicationService: ReplaceBrowserExtensionApplicationService {
        return ApplicationServiceRegistry.replaceExtensionService
    }

    override func setUp() {
        super.setUp()
        let intro = RBEIntroViewController.create()
        intro.starter = applicationService
        intro.delegate = self
        push(intro)
        introVC = intro
    }

}

extension ReplaceBrowserExtensionFlowCoordinator: RBEIntroViewControllerDelegate {

    func rbeIntroViewControllerDidStart() {
        self.transactionID = introVC!.transactionID
        let controller = PairWithBrowserExtensionViewController.createRBEConnectController(delegate: self)
        push(controller)
    }

}

extension ReplaceBrowserExtensionFlowCoordinator: PairWithBrowserExtensionViewControllerDelegate {

    func pairWithBrowserExtensionViewController(_ controller: PairWithBrowserExtensionViewController,
                                                didScanAddress address: String,
                                                code: String) throws {
        try applicationService.connect(transaction: transactionID, code: code)
    }

    func pairWithBrowserExtensionViewControllerDidFinish() {
        let controller = RecoveryPhraseInputViewController.create(delegate: self)
        push(controller)
    }

}

extension ReplaceBrowserExtensionFlowCoordinator: RecoveryPhraseInputViewControllerDelegate {


    func recoveryPhraseInputViewController(_ controller: RecoveryPhraseInputViewController,
                                           didEnterPhrase phrase: String) {
        do {
            try applicationService.sign(transaction: transactionID, withPhrase: phrase)
            controller.handleSuccess()
        } catch {
            controller.handleError(error)
        }
    }


    func recoveryPhraseInputViewControllerDidFinish() {
        let controller = ReplaceBrowserExtensionReviewTransactionViewController(transactionID: transactionID,
                                                                                delegate: self)
        push(controller)
    }

}

extension ReplaceBrowserExtensionFlowCoordinator: ReviewTransactionViewControllerDelegate {

    func wantsToSubmitTransaction(_ completion: @escaping (Bool) -> Void) {
        completion(true)
    }

    func didFinishReview() {
        applicationService.startMonitoring(transaction: transactionID)
        exitFlow()
    }

}
