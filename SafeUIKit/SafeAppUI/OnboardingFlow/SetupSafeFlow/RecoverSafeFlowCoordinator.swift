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

        push(GuidelinesViewController.createRecoverSafeGuidelines(delegate: self))
        saveCheckpoint()

        if ApplicationServiceRegistry.recoveryService.isRecoveryInProgress() {
            push(RecoveryInProgressViewController.create(delegate: self))
        }
    }

    func showReview() {
        let controller = ReviewRecoveryTransactionViewController.create(delegate: self)
        let navigationVC = UINavigationController(rootViewController: controller)
        presentModally(navigationVC)
    }

}

extension RecoverSafeFlowCoordinator: GuidelinesViewControllerDelegate {

    func didPressNext() {
        push(AddressInputViewController.create(delegate: self))
    }

}

extension RecoverSafeFlowCoordinator: AddressInputViewControllerDelegate {

    func addressInputViewControllerDidPressNext() {
        push(RecoveryPhraseInputViewController.create(delegate: self))
    }

}

extension RecoverSafeFlowCoordinator: RecoveryPhraseInputViewControllerDelegate {

    func recoveryPhraseInputViewControllerDidPressNext() {
        push(newPairController())
    }

    func newPairController() -> PairWithBrowserExtensionViewController {
        let controller = PairWithBrowserExtensionViewController.create(delegate: self)
        controller.screenTitle = nil
        controller.screenHeader = LocalizedString("recovery.browser_extension.header",
                                                  comment: "Header for connect browser extension screen")
        controller.descriptionText = LocalizedString("recovery.browser_extension.description",
                                                     comment: "Description for connect browser extension screen")
        return controller
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
            self.push(RecoveryInProgressViewController.create(delegate: self))
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
        let url = ApplicationServiceRegistry.walletService.transactionURL(transactionID)!
        let controller = SFSafariViewController(url: url)
        presentModally(controller)
    }

}
