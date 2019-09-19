//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication

class ReplaceTwoFAFlowCoordinator: FlowCoordinator {

    weak var introVC: RBEIntroViewController?
    var transactionID: RBETransactionID!
    var keycardFlowCoordinator = SKKeycardFlowCoordinator()
    var mainFlowCoordinator: MainFlowCoordinator!
    var twoFAMethod: String?

    private var applicationService: ReplaceTwoFAApplicationService {
        return ApplicationServiceRegistry.replaceTwoFAService
    }

    enum Strings {
        static let replaceTwoFA = LocalizedString("replace_2fa", comment: "Replace 2FA")
        static let replaceTwoFADescription = LocalizedString("replace_2fa_description",
                                                             comment: "Replace 2FA description")
        static let replaceTwoFAReviewDescription = LocalizedString("replace_2fa_review_description",
                                                                   comment: "Replace 2FA review description")
        static let statusKeyacard = LocalizedString("status_keycard", comment: "Status Keycard")
        static let gnosisSafeAuthenticator = LocalizedString("gnosis_safe_authenticator",
                                                             comment: "Gnosis Safe Authenticator")
    }

    override func setUp() {
        super.setUp()
        let vc = introViewController()
        push(vc)
        introVC = vc
    }

}

extension IntroContentView.Content {

    static let replaceTwoFAContent =
        IntroContentView
            .Content(body: ReplaceTwoFAFlowCoordinator.Strings.replaceTwoFADescription,
                     icon: Asset.Manage2fa._2FaReplace.image)

}

/// Screens factory methods
extension ReplaceTwoFAFlowCoordinator {

    func introViewController() -> RBEIntroViewController {
        let intro = RBEIntroViewController.create()
        intro.starter = applicationService
        intro.delegate = self
        intro.screenTrackingEvent = ReplaceTwoFATrackingEvent.intro
        intro.setTitle(Strings.replaceTwoFA)
        intro.setContent(.replaceTwoFAContent)
        return intro
    }

    func pairWithTwoFA() -> TwoFATableViewController {
        let controller = TwoFATableViewController()
        controller.delegate = self
        return controller
    }

    func connectAuthenticatorViewController() -> AuthenticatorViewController {
        let controller = AuthenticatorViewController.createRBEConnectController(delegate: self)
        controller.screenTrackingEvent = ReplaceTwoFATrackingEvent.scan
        return controller
    }

    func phraseInputViewController() -> RecoveryPhraseInputViewController {
        let controller = RecoveryPhraseInputViewController.create(delegate: self)
        controller.screenTrackingEvent = ReplaceTwoFATrackingEvent.enterSeed
        return controller
    }

    func reviewViewController() -> RBEReviewTransactionViewController {
        let controller = RBEReviewTransactionViewController(transactionID: transactionID, delegate: self)
        controller.titleString = Strings.replaceTwoFA
        controller.detailString = String(format: Strings.replaceTwoFAReviewDescription, twoFAMethod ?? "")
        controller.screenTrackingEvent = ReplaceTwoFATrackingEvent.review
        controller.successTrackingEvent = ReplaceTwoFATrackingEvent.success
        return controller
    }

}

extension ReplaceTwoFAFlowCoordinator: RBEIntroViewControllerDelegate {

    func rbeIntroViewControllerDidStart() {
        self.transactionID = introVC!.transactionID
        push(pairWithTwoFA())
    }

}

extension ReplaceTwoFAFlowCoordinator: TwoFATableViewControllerDelegate {

    func didSelectTwoFAOption(_ option: TwoFAOption) {
        switch option {
        case .statusKeycard:
            twoFAMethod = Strings.statusKeyacard
            applicationService.updateTransaction(transactionID, with: .replaceTwoFAWithStatusKeycard)
            keycardFlowCoordinator.mainFlowCoordinator = mainFlowCoordinator
            keycardFlowCoordinator.hidesSteps = true
            keycardFlowCoordinator.removesKeycardOnGoingBack = false
            let transactionID = self.transactionID!
            keycardFlowCoordinator.onSucces = { address in
                try ApplicationServiceRegistry.replaceTwoFAService.connectKeycard(transactionID, address: address)
            }
            enter(flow: keycardFlowCoordinator) { [unowned self] in
                self.push(self.phraseInputViewController())
            }
        case .gnosisAuthenticator:
            twoFAMethod = Strings.gnosisSafeAuthenticator
            applicationService.updateTransaction(transactionID, with: .replaceTwoFAWithAuthenticator)
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

extension ReplaceTwoFAFlowCoordinator: AuthenticatorViewControllerDelegate {

    func authenticatorViewController(_ controller: AuthenticatorViewController,
                                     didScanAddress address: String,
                                     code: String) throws {
        try applicationService.connect(transaction: transactionID, code: code)
    }

    func authenticatorViewControllerDidFinish() {
        push(phraseInputViewController())
    }

    func didSelectOpenAuthenticatorInfo() {
        SupportFlowCoordinator(from: self).openAuthenticatorInfo()
    }

}

extension ReplaceTwoFAFlowCoordinator: RecoveryPhraseInputViewControllerDelegate {

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

extension ReplaceTwoFAFlowCoordinator: ReviewTransactionViewControllerDelegate {

    func reviewTransactionViewControllerWantsToSubmitTransaction(_ controller: ReviewTransactionViewController,
                                                                 completion: @escaping (Bool) -> Void) {
        completion(true)
    }

    func reviewTransactionViewControllerDidFinishReview(_ controller: ReviewTransactionViewController) {
        DispatchQueue.global.async {
            self.applicationService.startMonitoring(transaction: self.transactionID)
        }
        push(SuccessViewController.replace2FASuccess(action: exitFlow))
    }

}

extension SuccessViewController {

    static func replace2FASuccess(action: @escaping () -> Void) -> SuccessViewController {
        return .congratulations(text: LocalizedString("tx_submitted_replace_be", comment: "Replacing"),
                                image: Asset.ReplaceBrowserExtension.inProgressIcon.image,
                                tracking: ReplaceTwoFATrackingEvent.success,
                                action: action)
    }

}
