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
        static let disconnectBE = LocalizedString("ios_disconnect_browser_extension",
                                                  comment: "Disconnect browser extension")
            .replacingOccurrences(of: "\n", with: " ")
        static let disconnectDescription = LocalizedString("disconnect_2fa_description",
                                                           comment: "Disconnect browser extension description")
        static let disconnectDetail = LocalizedString("layout_disconnect_browser_extension_info_description",
                                                      comment: "Detail for the header in review screen")
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
        vc.starter = ApplicationServiceRegistry.disconnectTwoFAService
        vc.delegate = self
        vc.setTitle(DisconnectTwoFAFlowCoordinator.Strings.introTitle)
        vc.setContent(.disconnectExtension)
        vc.screenTrackingEvent = DisconnectBrowserExtensionTrackingEvent.intro
        return vc
    }

    func phraseInputViewController() -> RecoveryPhraseInputViewController {
        let controller = RecoveryPhraseInputViewController.create(delegate: self)
        controller.screenTrackingEvent = DisconnectBrowserExtensionTrackingEvent.enterSeed
        return controller
    }

    func reviewViewController() -> RBEReviewTransactionViewController {
        let vc = RBEReviewTransactionViewController(transactionID: transactionID, delegate: self)
        vc.titleString = Strings.disconnectBE
        vc.detailString = Strings.disconnectDetail
        vc.screenTrackingEvent = DisconnectBrowserExtensionTrackingEvent.review
        vc.successTrackingEvent = DisconnectBrowserExtensionTrackingEvent.success
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
        push(SuccessViewController.disconnect2FASuccess(action: exitFlow))
    }

}

extension SuccessViewController {

    static func disconnect2FASuccess(action: @escaping () -> Void) -> SuccessViewController {
        return .congratulations(text: LocalizedString("disconnecting_in_progress", comment: "Explanation text"),
                                image: Asset.Manage2fa._2FaDisable.image,
                                tracking: DisconnectBrowserExtensionTrackingEvent.success,
                                action: action)
    }

}
