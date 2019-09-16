//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication

class ConnectTwoFAFlowCoordinator: FlowCoordinator {

    weak var intro: RBEIntroViewController!
    var transactionID: RBETransactionID!
    var transactionSubmissionHandler = TransactionSubmissionHandler()

    enum Strings {
        static let pairTwoFA = LocalizedString("pair_2FA_device", comment: "Pair 2FA device")
        static let connectBE = LocalizedString("ios_connect_browser_extension", comment: "Connect browser extension")
            .replacingOccurrences(of: "\n", with: " ")
        static let pairDescription = LocalizedString("pair_2FA_device_description",
                                                     comment: "Pair 2FA device description")
        static let connectAuthenticatorDetail = LocalizedString("layout_connect_browser_extension_info_description",
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

    static let pairTwoFAContent =
        IntroContentView
            .Content(body: ConnectTwoFAFlowCoordinator.Strings.pairDescription,
                     icon: Asset.CreateSafe.setup2FA.image)

}

/// Screens factory methods
extension ConnectTwoFAFlowCoordinator {

    func introViewController() -> RBEIntroViewController {
        let vc = RBEIntroViewController.create()
        vc.starter = ApplicationServiceRegistry.connectExtensionService
        vc.delegate = self
        vc.setTitle(Strings.pairTwoFA)
        vc.setContent(.pairTwoFAContent)
        vc.screenTrackingEvent = ConnectTwoFATrackingEvent.intro
        return vc
    }

    func pairViewController() -> TwoFAViewController {
        return TwoFAViewController.createRBEConnectController(delegate: self)
    }

    func reviewViewController() -> RBEReviewTransactionViewController {
        let vc = RBEReviewTransactionViewController(transactionID: transactionID, delegate: self)
        vc.titleString = Strings.connectBE
        vc.detailString = Strings.connectAuthenticatorDetail
        vc.screenTrackingEvent = ConnectTwoFATrackingEvent.review
        vc.successTrackingEvent = ConnectTwoFATrackingEvent.success
        return vc
    }

}

extension ConnectTwoFAFlowCoordinator: RBEIntroViewControllerDelegate {

    func rbeIntroViewControllerDidStart() {
        transactionID = intro.transactionID
        push(pairViewController())
    }

}

extension ConnectTwoFAFlowCoordinator: TwoFAViewControllerDelegate {

    func twoFAViewController(_ controller: TwoFAViewController, didScanAddress address: String, code: String) throws {
        try ApplicationServiceRegistry.connectExtensionService.connect(transaction: transactionID, code: code)
    }

    func twoFAViewControllerDidFinish() {
        push(reviewViewController())
    }

    func didSelectOpenAuthenticatorInfo() {
        SupportFlowCoordinator(from: self).openAuthenticatorInfo()
    }

}

extension ConnectTwoFAFlowCoordinator: ReviewTransactionViewControllerDelegate {

    func reviewTransactionViewControllerWantsToSubmitTransaction(_ controller: ReviewTransactionViewController,
                                                                 completion: @escaping (Bool) -> Void) {
        transactionSubmissionHandler.submitTransaction(from: self, completion: completion)
    }

    func reviewTransactionViewControllerDidFinishReview(_ controller: ReviewTransactionViewController) {
        DispatchQueue.global.async {
            ApplicationServiceRegistry.connectExtensionService.startMonitoring(transaction: self.transactionID)
        }
        push(SuccessViewController.connect2FASuccess(action: exitFlow))
    }

}

extension SuccessViewController {

    static func connect2FASuccess(action: @escaping () -> Void) -> SuccessViewController {
        return .congratulations(text: LocalizedString("connecting_in_progress", comment: "Explanation text"),
                                image: Asset.CreateSafe.setup2FA.image,
                                tracking: ConnectTwoFATrackingEvent.success,
                                action: action)
    }

}
