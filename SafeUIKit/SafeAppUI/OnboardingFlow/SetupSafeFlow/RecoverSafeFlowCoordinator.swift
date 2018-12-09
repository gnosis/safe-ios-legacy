//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication

final class RecoverSafeFlowCoordinator: FlowCoordinator {

    override func setUp() {
        super.setUp()
        push(GuidelinesViewController.createRecoverSafeGuidelines(delegate: self))
    }

    func showReview() {
        presentModally(ReviewRecoveryTransactionViewController.create())
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
                                                didPairWith address: String,
                                                code: String) {
        do {
            try ApplicationServiceRegistry.walletService
                .addBrowserExtensionOwner(address: address, browserExtensionCode: code)
            showReview()
        } catch let e {
            controller.handleError(e)
        }
    }

    func pairWithBrowserExtensionViewControllerDidSkipPairing() {
        ApplicationServiceRegistry.walletService.removeBrowserExtensionOwner()
        showReview()
    }

}
