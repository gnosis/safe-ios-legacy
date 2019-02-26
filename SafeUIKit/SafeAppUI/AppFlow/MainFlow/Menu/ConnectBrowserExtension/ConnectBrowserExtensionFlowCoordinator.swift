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
        vc.starter = ApplicationServiceRegistry.settingsService
        push(vc)
        intro = vc
    }

}

extension ConnectBrowserExtensionFlowCoordinator: RBEIntroViewControllerDelegate {

    func rbeIntroViewControllerDidStart() {
        transactionID = intro.transactionID
        let vc = PairWithBrowserExtensionViewController.create(delegate: self)
        push(vc)
    }

}

extension ConnectBrowserExtensionFlowCoordinator: PairWithBrowserExtensionViewControllerDelegate {

    func pairWithBrowserExtensionViewController(_ controller: PairWithBrowserExtensionViewController,
                                                didScanAddress address: String,
                                                code: String) throws {
        try ApplicationServiceRegistry.settingsService.connect(transaction: transactionID, code: code)
    }

    func pairWithBrowserExtensionViewControllerDidFinish() {
        let vc = FundsTransferReviewTransactionViewController(transactionID: transactionID, delegate: self)
        push(vc)
    }

}

extension ConnectBrowserExtensionFlowCoordinator: ReviewTransactionViewControllerDelegate {

    func wantsToSubmitTransaction(_ completion: @escaping (Bool) -> Void) {
        transactionSubmissionHandler.submitTransaction(from: self, completion: completion)
    }

    func didFinishReview() {
        ApplicationServiceRegistry.settingsService.startMonitoring(transaction: transactionID)
        exitFlow()
    }

}
