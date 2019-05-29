//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication
import SafariServices
import Common

final class RecoverSafeFlowCoordinator: FlowCoordinator {

    let flowTitle: String = LocalizedString("recover_safe_title", comment: "Recover Safe")
    weak var mainFlowCoordinator: MainFlowCoordinator!

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

    func inProgressViewController() -> UIViewController {
        return RecoverFeePaidViewController.create(delegate: self)
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
        push(RecoverRecoveryFeeViewController.create(delegate: self))
    }

}

extension RecoverSafeFlowCoordinator: RecoverRecoveryFeeViewControllerDelegate {

    func recoverRecoveryFeeViewControllerDidBecomeReadyToSubmit() {
        let tx = ApplicationServiceRegistry.recoveryService.recoveryTransaction()!
        let controller = RecoverReviewViewController(transactionID: tx.id, delegate: self)
        var stack = navigationController.viewControllers
        stack.removeLast()
        stack.append(controller)
        navigationController.viewControllers = stack
    }

    func recoverRecoveryFeeViewControllerDidCancel() {
        exitFlow()
    }

}

extension RecoverSafeFlowCoordinator: ReviewTransactionViewControllerDelegate {

    func reviewTransactionViewControllerDidFinishReview(_ controller: ReviewTransactionViewController) {
        push(inProgressViewController())
    }

    func reviewTransactionViewControllerWantsToSubmitTransaction(_ controller: ReviewTransactionViewController,
                                                                 completion: @escaping (Bool) -> Void) {
        completion(true)
    }

}

extension RecoverSafeFlowCoordinator: RecoverFeePaidViewControllerDelegate {

    func recoverFeePaidViewControllerOpenMenu() {
        mainFlowCoordinator.openMenu()
    }

    func recoverFeePaidViewControllerWantsToOpenTransactionInExternalViewer(_ transactionID: String) {
        SupportFlowCoordinator(from: self).openTransactionBrowser(transactionID)
    }

    func recoverFeePaidViewControllerDidFail() {
        exitFlow()
    }

    func recoverFeePaidViewControllerDidSuccess() {
        exitFlow()
    }

}
