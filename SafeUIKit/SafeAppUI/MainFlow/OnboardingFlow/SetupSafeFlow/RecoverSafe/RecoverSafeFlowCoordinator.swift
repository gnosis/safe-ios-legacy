//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication
import SafariServices
import Common

final class RecoverSafeFlowCoordinator: FlowCoordinator {

    let flowTitle: String = LocalizedString("recover_safe_title", comment: "Recover Safe")

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
        controller.screenTitle = flowTitle
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
        controller.title = flowTitle
        return controller
    }

    func showPaymentIntro() {
        let controller = OnboardingCreationFeeIntroViewController.create(delegate: self)
        controller.titleText = flowTitle
        push(controller)
    }

    func showReview() {
        let controller = ReviewRecoveryTransactionViewController.create(delegate: self)
        push(controller)
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
        showPaymentIntro()
    }

    func twoFAViewControllerDidSkipPairing() {
        ApplicationServiceRegistry.walletService.removeBrowserExtensionOwner()
        showPaymentIntro()
    }

}

extension RecoverSafeFlowCoordinator: CreationFeePaymentMethodDelegate {

    func creationFeePaymentMethodPay() {
        creationFeeIntroPay()
    }

    func creationFeePaymentMethodLoadEstimates() -> [TokenData] {
        return creationFeeLoadEstimates()
    }

}

extension RecoverSafeFlowCoordinator: CreationFeeIntroDelegate {

    func creationFeeLoadEstimates() -> [TokenData] {
        return ApplicationServiceRegistry.recoveryService.estimateRecoveryTransaction()
    }

    func creationFeeNetworkFeeAlert() -> UIAlertController {
        return .recoveryFee()
    }

    func creationFeeIntroChangePaymentMethod(estimations: [TokenData]) {
        push(OnboardingPaymentMethodViewController.create(delegate: self, estimations: estimations))
    }

    func creationFeeIntroPay() {
        var stack = navigationController.viewControllers
        stack.removeLast()
        stack.append(RecoverRecoveryFeeViewController.create(delegate: self))
        navigationController.viewControllers = stack
    }

}

extension RecoverSafeFlowCoordinator: RecoverRecoveryFeeViewControllerDelegate {

    func recoverRecoveryFeeViewControllerDidBecomeReadyToSubmit() {
        showReview()
    }

    func recoverRecoveryFeeViewControllerDidCancel() {
        exitFlow()
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
