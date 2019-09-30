//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication

class DisconnectTwoFAFlowCoordinator: FlowCoordinator {

    weak var introVC: RBEIntroViewController!
    var transactionID: RBETransactionID!
    fileprivate var applicationService: DisconnectTwoFAApplicationService {
        return ApplicationServiceRegistry.disconnectTwoFAService
    }

    enum Strings {
        static let introTitle = LocalizedString("disable_2fa", comment: "Disable 2FA")
        static let disconnectDescription = LocalizedString("disable_2fa_description",
                                                           comment: "Disable 2FA description")
        static let disconnectReviewDescription = LocalizedString("disable_2fa_review_description",
                                                                 comment: "Disable 2FA review description")
        static let statusKeyacard = LocalizedString("status_keycard", comment: "Status Keycard")
        static let gnosisSafeAuthenticator = LocalizedString("gnosis_safe_authenticator",
                                                             comment: "Gnosis Safe Authenticator")
    }

    override func setUp() {
        super.setUp()
        introVC = introViewController()
        push(introVC)
    }

}

extension IntroContentView.Content {

    static let disconnectExtension =
        IntroContentView
            .Content(body: DisconnectTwoFAFlowCoordinator.Strings.disconnectDescription,
                     icon: Asset.Manage2fa._2FaDisable.image)

}

/// Screen constructors in the flow
extension DisconnectTwoFAFlowCoordinator {

    func introViewController() -> RBEIntroViewController {
        let vc = RBEIntroViewController.create()
        vc.starter = applicationService
        vc.delegate = self
        vc.setTitle(Strings.introTitle)
        vc.setContent(.disconnectExtension)
        vc.screenTrackingEvent = DisconnectTwoFATrackingEvent.intro
        return vc
    }

    func phraseInputViewController() -> RecoveryPhraseInputViewController {
        let controller = RecoveryPhraseInputViewController.create(delegate: self)
        controller.screenTrackingEvent = DisconnectTwoFATrackingEvent.enterSeed
        return controller
    }

    func reviewViewController() -> RBEReviewTransactionViewController {
        var twoFAMethod: String!
        let transactionType = ApplicationServiceRegistry.walletService.transactionData(transactionID)!.type
        switch transactionType {
        case .disconnectAuthenticator: twoFAMethod = Strings.gnosisSafeAuthenticator
        case .disconnectStatusKeycard: twoFAMethod = Strings.statusKeyacard
        default: break
        }

        let vc = RBEReviewTransactionViewController(transactionID: transactionID, delegate: self)
        vc.titleString = Strings.introTitle
        vc.detailString = String(format: Strings.disconnectReviewDescription, twoFAMethod)
        vc.screenTrackingEvent = DisconnectTwoFATrackingEvent.review
        vc.successTrackingEvent = DisconnectTwoFATrackingEvent.success
        return vc
    }

}

extension DisconnectTwoFAFlowCoordinator: RBEIntroViewControllerDelegate {

    func rbeIntroViewControllerDidStart() {
        self.transactionID = introVC!.transactionID
        push(phraseInputViewController())
    }

}

extension DisconnectTwoFAFlowCoordinator: RecoveryPhraseInputViewControllerDelegate {

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

extension DisconnectTwoFAFlowCoordinator: ReviewTransactionViewControllerDelegate {

    func reviewTransactionViewControllerWantsToSubmitTransaction(_ controller: ReviewTransactionViewController,
                                                                 completion: @escaping (Bool) -> Void) {
        completion(true)
    }

    func reviewTransactionViewControllerDidFinishReview(_ controller: ReviewTransactionViewController) {
        DispatchQueue.global.async {
            self.applicationService.startMonitoring(transaction: self.transactionID)
        }
        push(SuccessViewController.disconnect2FASuccess { [unowned self] in
            self.exitFlow()
        })
    }

}

extension SuccessViewController {

    static func disconnect2FASuccess(action: @escaping () -> Void) -> SuccessViewController {
        return .congratulations(text: LocalizedString("disconnecting_in_progress", comment: "Explanation text"),
                                image: Asset.Manage2fa._2FaDisable.image,
                                tracking: DisconnectTwoFATrackingEvent.success,
                                action: action)
    }

}
