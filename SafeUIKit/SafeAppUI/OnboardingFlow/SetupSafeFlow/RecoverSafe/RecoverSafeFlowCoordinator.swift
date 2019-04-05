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
            return
        }

        push(introViewController())
        saveCheckpoint()

        if ApplicationServiceRegistry.recoveryService.isRecoveryInProgress() {
            push(inProgressViewController())
        }
    }

    func showReview() {
        presentModally(reviewNavigationController())
    }

}

/// Constructors of the screens participating in the flow
extension RecoverSafeFlowCoordinator {

    func introViewController() -> GuidelinesViewController {
        let controller = GuidelinesViewController.createRecoverSafeGuidelines(delegate: self)
        controller.screenTrackingEvent = RecoverSafeTrackingEvent.intro
        return controller
    }

    func inProgressViewController() -> RecoveryInProgressViewController {
        return RecoveryInProgressViewController.create(delegate: self)
    }

    func newPairController() -> PairWithBrowserExtensionViewController {
        let controller = PairWithBrowserExtensionViewController.create(delegate: self)
        controller.screenTitle = nil
        controller.screenHeader = LocalizedString("recovery.browser_extension.header",
                                                  comment: "Header for connect browser extension screen")
        controller.descriptionText = LocalizedString("recovery.browser_extension.description",
                                                     comment: "Description for connect browser extension screen")
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
        return controller
    }

    func reviewNavigationController() -> UINavigationController {
        let controller = ReviewRecoveryTransactionViewController.create(delegate: self)
        let navigationVC = UINavigationController(rootViewController: controller)
        return navigationVC
    }
}

extension RecoverSafeFlowCoordinator: GuidelinesViewControllerDelegate {

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

extension RecoverSafeFlowCoordinator: PairWithBrowserExtensionViewControllerDelegate {

    func pairWithBrowserExtensionViewController(_ controller: PairWithBrowserExtensionViewController,
                                                didScanAddress address: String,
                                                code: String) throws {
        try ApplicationServiceRegistry.walletService
            .addBrowserExtensionOwner(address: address, browserExtensionCode: code)
    }

    func pairWithBrowserExtensionViewControllerDidFinish() {
        showReview()
    }

    func pairWithBrowserExtensionViewControllerDidSkipPairing() {
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
            self.popToLastCheckpoint()
        }
    }

}

extension RecoverSafeFlowCoordinator: RecoveryInProgressViewControllerDelegate {

    func recoveryInProgressViewControllerDidFail() {
        popToLastCheckpoint()
    }

    func recoveryInProgressViewControllerDidSuccess() {
        exitFlow()
    }

    func recoveryInProgressViewControllerWantsToOpenTransactionInExternalViewer(_ transactionID: String) {
        SupportFlowCoordinator(from: self).openTransactionBrowser(transactionID)
    }

}
