//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication

class ConnectTwoFAFlowCoordinator: FlowCoordinator {

    weak var intro: RBEIntroViewController!
    var transactionID: RBETransactionID!
    var transactionSubmissionHandler = TransactionSubmissionHandler()
    var keycardFlowCoordinator = SKKeycardFlowCoordinator()
    var mainFlowCoordinator: MainFlowCoordinator!

    enum Strings {
        static let pairTwoFA = LocalizedString("pair_2FA_device", comment: "Pair 2FA device")
        static let pairDescription = LocalizedString("pair_2FA_device_description",
                                                     comment: "Pair 2FA device description")
        static let pairReviewDescription = LocalizedString("pair_2fa_review_description",
                                                           comment: "Pair 2FA review description")
        static let statusKeyacard = LocalizedString("status_keycard", comment: "Status Keycard")
        static let gnosisSafeAuthenticator = LocalizedString("gnosis_safe_authenticator",
                                                             comment: "Gnosis Safe Authenticator")
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

    func pairWithTwoFA() -> TwoFATableViewController {
        let controller = TwoFATableViewController()
        controller.delegate = self
        return controller
    }

    func connectAuthenticatorViewController() -> TwoFAViewController {
        return TwoFAViewController.createRBEConnectController(delegate: self)
    }

    func reviewConnectAuthenticatorViewController() -> RBEReviewTransactionViewController {
        return reviewTransactionVC(placeholderValue: Strings.gnosisSafeAuthenticator)
    }

    func reviewConnectKeycardViewController() -> RBEReviewTransactionViewController {
        return reviewTransactionVC(placeholderValue: Strings.statusKeyacard)
    }

    private func reviewTransactionVC(placeholderValue: String) -> RBEReviewTransactionViewController {
        let vc = RBEReviewTransactionViewController(transactionID: transactionID, delegate: self)
        vc.titleString = Strings.pairTwoFA
        vc.detailString = String(format: Strings.pairReviewDescription, placeholderValue)
        vc.screenTrackingEvent = ConnectTwoFATrackingEvent.review
        vc.successTrackingEvent = ConnectTwoFATrackingEvent.success
        return vc
    }

}

extension ConnectTwoFAFlowCoordinator: RBEIntroViewControllerDelegate {

    func rbeIntroViewControllerDidStart() {
        transactionID = intro.transactionID
        push(pairWithTwoFA())
    }

}

extension ConnectTwoFAFlowCoordinator: TwoFATableViewControllerDelegate {

    func didSelectTwoFAOption(_ option: TwoFAOption) {
        switch option {
        case .statusKeycard:
            keycardFlowCoordinator.mainFlowCoordinator = mainFlowCoordinator
            enter(flow: keycardFlowCoordinator) { [unowned self] in
                self.push(self.reviewConnectKeycardViewController())
            }
        case .gnosisAuthenticator:
            push(connectAuthenticatorViewController())
        }
    }

    func didSelectLearnMore(for option: TwoFAOption) {
        let supportCoordinator = SupportFlowCoordinator(from: self)
        switch option {
        case .gnosisAuthenticator:
            supportCoordinator.openAuthenticatorInfo()
        case .statusKeycard:
            supportCoordinator.openStausKeycardInfo()
        }
    }

}

extension ConnectTwoFAFlowCoordinator: TwoFAViewControllerDelegate {

    func twoFAViewController(_ controller: TwoFAViewController, didScanAddress address: String, code: String) throws {
        try ApplicationServiceRegistry.connectExtensionService.connect(transaction: transactionID, code: code)
    }

    func twoFAViewControllerDidFinish() {
        push(reviewConnectAuthenticatorViewController())
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
