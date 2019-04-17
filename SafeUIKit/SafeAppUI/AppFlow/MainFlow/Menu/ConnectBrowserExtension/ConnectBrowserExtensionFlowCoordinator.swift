//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication

class ConnectBrowserExtensionFlowCoordinator: FlowCoordinator {

    weak var intro: RBEIntroViewController!
    var transactionID: RBETransactionID!
    var transactionSubmissionHandler = TransactionSubmissionHandler()

    enum Strings {
        static let connectBE = LocalizedString("connect_browser_extension", comment: "Connect browser extension")
            .replacingOccurrences(of: "\n", with: " ")
        static let connectDescription = LocalizedString("ios_enable_2fa",
                                                        comment: "Connect browser extension description")
        static let connectDetail = LocalizedString("layout_connect_browser_extension_info_description",
                                                   comment: "Detail for the header in review screen")
    }

    override func setUp() {
        super.setUp()
        intro = introViewController()
        push(intro)
    }

}

extension IntroContentView.Content {

    static let connectExtension =
        IntroContentView
            .Content(header: ConnectBrowserExtensionFlowCoordinator.Strings.connectBE,
                     body: ConnectBrowserExtensionFlowCoordinator.Strings.connectDescription,
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
        vc.titleString = Strings.connectBE
        vc.detailString = Strings.connectDetail
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
