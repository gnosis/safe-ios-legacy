//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication
import SafariServices

final class RecoverSafeFlowCoordinator: FlowCoordinator {

    override func setUp() {
        super.setUp()
        if ApplicationServiceRegistry.walletService.hasReadyToUseWallet {
            exitFlow()
        } else if ApplicationServiceRegistry.recoveryService.isRecoveryInProgress() {
            push(inProgressViewController())
        } else {
            push(introViewController())
        }
    }

}

/// Constructors of the screens participating in the flow
extension RecoverSafeFlowCoordinator {

    func introViewController() -> OnboardingIntroViewController {
        let controller = OnboardingIntroViewController.createRecoverSafeIntro(delegate: self)
        controller.screenTrackingEvent = RecoverSafeTrackingEvent.intro
        return controller
    }

    func inProgressViewController() -> RecoveryInProgressViewController {
        return RecoveryInProgressViewController.create(delegate: self)
    }

    func newPairController() -> TwoFAViewController {
        let controller = TwoFAViewController.create(delegate: self)
        controller.screenTitle = LocalizedString("recover_safe_title", comment: "Recover Safe")
        controller.screenHeader = LocalizedString("ios_connect_browser_extension",
                                                  comment: "Header for add browser extension screen")
        controller.descriptionText = LocalizedString("enable_2fa",
                                                     comment: "Description for add browser extension screen")
        controller.screenTrackingEvent = RecoverSafeTrackingEvent.twoFA
        controller.scanTrackingEvent = RecoverSafeTrackingEvent.twoFAScan
        return controller
    }

    func addressViewController() -> AddressInputViewController {
        return AddressInputViewController.create(delegate: self)
    }

    func recoveryPhraseViewController() -> RecoveryPhraseInputViewController {
        let controller = RecoveryPhraseInputViewController.create(delegate: self)
        controller.screenTrackingEvent = RecoverSafeTrackingEvent.enterSeed
        controller.title = LocalizedString("recover_safe_title", comment: "Recover safe")
        return controller
    }

    func reviewNavigationController() -> UINavigationController {
        let controller = ReviewRecoveryTransactionViewController.create(delegate: self)
        let navigationVC = UINavigationController(rootViewController: controller)
        return navigationVC
    }

    func showReview() {
        presentModally(reviewNavigationController())
    }

}

extension RecoverSafeFlowCoordinator: OnboardingIntroViewControllerDelegate {

    func didPressNext() {
        push(addressViewController())
    }

}

extension RecoverSafeFlowCoordinator: AddressInputViewControllerDelegate {

    func addressInputViewControllerDidPressNext() {
        push(recoveryPhraseViewController())
    }

}

extension RecoverSafeFlowCoordinator: RecoveryPhraseInputViewControllerDelegate {

    func recoveryPhraseInputViewController(_ controller: RecoveryPhraseInputViewController,
                                           didEnterPhrase phrase: String) {
        DispatchQueue.global().async {
            ApplicationServiceRegistry.recoveryService.provide(recoveryPhrase: phrase,
                                                               subscriber: controller) { error in
                                                                controller.handleError(error)
            }
        }
    }

    func recoveryPhraseInputViewControllerDidFinish() {
        push(newPairController())
    }

}

extension RecoverSafeFlowCoordinator: TwoFAViewControllerDelegate {

    func twoFAViewController(_ controller: TwoFAViewController, didScanAddress address: String, code: String) throws {
        try ApplicationServiceRegistry.walletService
            .addBrowserExtensionOwner(address: address, browserExtensionCode: code)
    }

    func twoFAViewControllerDidFinish() {
        showReview()
    }

    func twoFAViewControllerDidSkipPairing() {
        ApplicationServiceRegistry.walletService.removeBrowserExtensionOwner()
        showReview()
    }

}

extension RecoverSafeFlowCoordinator: ReviewRecoveryTransactionViewControllerDelegate {

    func reviewRecoveryTransactionViewControllerDidSubmit() {
        dismissModal { [unowned self] in
            self.push(self.inProgressViewController())
        }
    }

    func reviewRecoveryTransactionViewControllerDidCancel() {
        dismissModal { [unowned self] in
            self.exitFlow()
        }
    }

}

extension RecoverSafeFlowCoordinator: RecoveryInProgressViewControllerDelegate {

    func recoveryInProgressViewControllerDidFail() {
        exitFlow()
    }

    func recoveryInProgressViewControllerDidSuccess() {
        exitFlow()
    }

    func recoveryInProgressViewControllerWantsToOpenTransactionInExternalViewer(_ transactionID: String) {
        SupportFlowCoordinator(from: self).openTransactionBrowser(transactionID)
    }

}
