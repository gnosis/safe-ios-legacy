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
        static let connectBE = LocalizedString("ios_connect_browser_extension", comment: "Connect browser extension")
            .replacingOccurrences(of: "\n", with: " ")
        static let connectDescription = LocalizedString("ios_enable_2fa",
                                                        comment: "Connect browser extension description")
        static let connectDetail = LocalizedString("layout_connect_browser_extension_info_description",
                                                   comment: "Detail for the header in review screen")
    }

    override func setUp() {
        super.setUp()
        let vc = introViewController()
        push(vc)
        intro = vc
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

    func pairViewController() -> TwoFAViewController {
        return TwoFAViewController.createRBEConnectController(delegate: self)
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

extension ConnectBrowserExtensionFlowCoordinator: TwoFAViewControllerDelegate {

    func twoFAViewController(_ controller: TwoFAViewController, didScanAddress address: String, code: String) throws {
        try ApplicationServiceRegistry.connectExtensionService.connect(transaction: transactionID, code: code)
    }

    func twoFAViewControllerDidFinish() {
        push(reviewViewController())
    }

}

extension ConnectBrowserExtensionFlowCoordinator: ReviewTransactionViewControllerDelegate {

    func reviewTransactionViewControllerWantsToSubmitTransaction(_ controller: ReviewTransactionViewController,
                                                                 completion: @escaping (Bool) -> Void) {
        transactionSubmissionHandler.submitTransaction(from: self, completion: completion)
    }

    func reviewTransactionViewControllerDidFinishReview(_ controller: ReviewTransactionViewController) {
        DispatchQueue.global.async {
            ApplicationServiceRegistry.connectExtensionService.startMonitoring(transaction: self.transactionID)
        }
        exitFlow()
    }

}
