//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication

typealias CBETransactionID = String

class ConnectBrowserExtensionFlowCoordinator: FlowCoordinator {

    weak var intro: CBEIntroViewController!
    var transactionID: CBETransactionID!
    var transactionSubmissionHandler = TransactionSubmissionHandler()

    override func setUp() {
        super.setUp()
        let vc = CBEIntroViewController.createConnectExtensionIntro()
        vc.delegate = self
        vc.starter = ApplicationServiceRegistry.connectExtensionService
        intro = vc
        push(vc)
    }

}

extension ConnectBrowserExtensionFlowCoordinator: RBEIntroViewControllerDelegate {

    func rbeIntroViewControllerDidStart() {
        transactionID = intro.transactionID
        let vc = PairWithBrowserExtensionViewController.createRBEConnectController(delegate: self)
        push(vc)
    }

}

extension ConnectBrowserExtensionFlowCoordinator: PairWithBrowserExtensionViewControllerDelegate {

    func pairWithBrowserExtensionViewController(_ controller: PairWithBrowserExtensionViewController,
                                                didScanAddress address: String,
                                                code: String) throws {
        try ApplicationServiceRegistry.connectExtensionService.connect(transaction: transactionID, code: code)
    }

    func pairWithBrowserExtensionViewControllerDidFinish() {
        let vc = RBEReviewTransactionViewController(transactionID: transactionID, delegate: self)
        vc.titleString = LocalizedString("connect_extension.review.title", comment: "Title for the header")
        vc.detailString = LocalizedString("connect_extension.review.detail", comment: "Detail for the header")
        push(vc)
    }

}

extension ConnectBrowserExtensionFlowCoordinator: ReviewTransactionViewControllerDelegate {

    func wantsToSubmitTransaction(_ completion: @escaping (Bool) -> Void) {
        transactionSubmissionHandler.submitTransaction(from: self, completion: completion)
    }

    func didFinishReview() {
        ApplicationServiceRegistry.connectExtensionService.startMonitoring(transaction: transactionID)
        exitFlow()
    }

}
