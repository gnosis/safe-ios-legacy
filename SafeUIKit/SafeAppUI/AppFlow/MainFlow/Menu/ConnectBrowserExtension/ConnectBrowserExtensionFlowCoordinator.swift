//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication

class ConnectBrowserExtensionFlowCoordinator: FlowCoordinator {

    weak var intro: RBEIntroViewController!
    var transactionID: RBETransactionID!
    var transactionSubmissionHandler = TransactionSubmissionHandler()

    override func setUp() {
        super.setUp()
        intro = introViewController()
        push(intro)
    }

}

extension IntroContentView.Content {

    static let connectExtension =
        IntroContentView.Content(header: LocalizedString("connect_extension.intro.header", comment: "Header label"),
                                 body: LocalizedString("connect_extension.intro.body", comment: "Body text"),
                                 icon: Asset.ConnectBrowserExtension.connectIntroIcon.image)

}

/// Screens factory methods
extension ConnectBrowserExtensionFlowCoordinator {

    func introViewController() -> RBEIntroViewController {
        let vc = RBEIntroViewController.create()
        vc.starter = ApplicationServiceRegistry.connectExtensionService
        vc.delegate = self
        vc.setContent(.connectExtension)
        vc.screenTrackingEvent = ConnectBrowserExtensionTrackingEvent.intro
        return vc
    }

    func pairViewController() -> PairWithBrowserExtensionViewController {
        return PairWithBrowserExtensionViewController.createRBEConnectController(delegate: self)
    }

    func reviewViewController() -> RBEReviewTransactionViewController {
        let vc = RBEReviewTransactionViewController(transactionID: transactionID, delegate: self)
        vc.titleString = LocalizedString("connect_extension.review.title", comment: "Title for the header")
        vc.detailString = LocalizedString("connect_extension.review.detail", comment: "Detail for the header")
        vc.screenTrackingEvent = ConnectBrowserExtensionTrackingEvent.review
        vc.successTrackingEvent = ConnectBrowserExtensionTrackingEvent.success
        return vc
    }

}

extension ConnectBrowserExtensionFlowCoordinator: RBEIntroViewControllerDelegate {

    func rbeIntroViewControllerDidStart() {
        transactionID = intro.transactionID
        push(pairViewController())
    }

}

extension ConnectBrowserExtensionFlowCoordinator: PairWithBrowserExtensionViewControllerDelegate {

    func pairWithBrowserExtensionViewController(_ controller: PairWithBrowserExtensionViewController,
                                                didScanAddress address: String,
                                                code: String) throws {
        try ApplicationServiceRegistry.connectExtensionService.connect(transaction: transactionID, code: code)
    }

    func pairWithBrowserExtensionViewControllerDidFinish() {
        push(reviewViewController())
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
