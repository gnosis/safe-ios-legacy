//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication

class ReplaceBrowserExtensionFlowCoordinator: FlowCoordinator {

    weak var introVC: RBEIntroViewController?
    var transactionID: RBETransactionID!

    private var applicationService: ReplaceBrowserExtensionApplicationService {
        return ApplicationServiceRegistry.replaceExtensionService
    }

    override func setUp() {
        super.setUp()
        let vc = introViewController()
        push(vc)
        introVC = vc
    }

}

/// Screens factory methods
extension ReplaceBrowserExtensionFlowCoordinator {

    func introViewController() -> RBEIntroViewController {
        let intro = RBEIntroViewController.create()
        intro.starter = applicationService
        intro.delegate = self
        intro.screenTrackingEvent = ReplaceBrowserExtensionTrackingEvent.intro
        return intro
    }

    func pairViewController() -> PairWithBrowserExtensionViewController {
        let controller = PairWithBrowserExtensionViewController.createRBEConnectController(delegate: self)
        controller.screenTrackingEvent = ReplaceBrowserExtensionTrackingEvent.scan
        return controller
    }

    func phraseInputViewController() -> RecoveryPhraseInputViewController {
        let controller = RecoveryPhraseInputViewController.create(delegate: self)
        controller.screenTrackingEvent = ReplaceBrowserExtensionTrackingEvent.enterSeed
        return controller
    }

    func reviewViewController() -> RBEReviewTransactionViewController {
        let controller = RBEReviewTransactionViewController(transactionID: transactionID, delegate: self)
        controller.screenTrackingEvent = ReplaceBrowserExtensionTrackingEvent.review
        controller.successTrackingEvent = ReplaceBrowserExtensionTrackingEvent.success
        return controller
    }

}

extension ReplaceBrowserExtensionFlowCoordinator: RBEIntroViewControllerDelegate {

    func rbeIntroViewControllerDidStart() {
        self.transactionID = introVC!.transactionID
        push(pairViewController())
    }

}

extension ReplaceBrowserExtensionFlowCoordinator: PairWithBrowserExtensionViewControllerDelegate {

    func pairWithBrowserExtensionViewController(_ controller: PairWithBrowserExtensionViewController,
                                                didScanAddress address: String,
                                                code: String) throws {
        try applicationService.connect(transaction: transactionID, code: code)
    }

    func pairWithBrowserExtensionViewControllerDidFinish() {
        push(phraseInputViewController())
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
        push(reviewViewController())
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
