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
    var keycardFlowCoordinator = SKKeycardFlowCoordinator()

    override func setUp() {
        super.setUp()
        if ApplicationServiceRegistry.walletService.hasReadyToUseWallet {
            exitFlow()
        } else if ApplicationServiceRegistry.recoveryService.isRecoveryInProgress() {
            showInProgress()
        } else {
            push(introViewController())
        }
    }

    func finish(from vc: UIViewController? = nil) {
        ApplicationServiceRegistry.walletService.cleanUpDrafts()
        if navigationController.topViewController === vc {
            mainFlowCoordinator.switchToRootController()
        }
        exitFlow()
    }

    override func setRoot(_ controller: UIViewController) {
        guard rootViewController !== controller else { return }
        super.setRoot(controller)
        [mainFlowCoordinator, keycardFlowCoordinator].forEach { $0?.setRoot(controller) }
    }

}

/// Constructors of the screens participating in the flow
extension RecoverSafeFlowCoordinator {

    func introViewController() -> OnboardingIntroViewController {
        let controller = OnboardingIntroViewController.createRecoverSafeIntro(delegate: self)
        controller.screenTrackingEvent = RecoverSafeTrackingEvent.intro
        return controller
    }

    func showInProgress() {
        if let existingVC = navigationController.topViewController as? RecoverFeePaidViewController,
            existingVC.walletID == ApplicationServiceRegistry.walletService.selectedWalletID() {
            return
        }
        let vc = RecoverFeePaidViewController.create(delegate: self)
        setRoot(CustomNavigationController(rootViewController: vc))
    }

    func newPairController() -> UIViewController {
        let controller = PairWith2FAController.create(onNext: { [unowned self] in
            let controller = TwoFATableViewController()
            controller.delegate = self
            self.push(controller)
        }, onSkip: { [unowned self] in
            self.showPaymentIntro()
        })
        controller.hidesStepView = true
        controller.navigationItem.backBarButtonItem = .backButton()
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
        controller.headerText = LocalizedString("safe_recovery_fee", comment: "Header for recover fee screen.")
        controller.descriptionText = LocalizedString("safe_recovery_fee_required", comment: "Description of a fee.")
        controller.screenTrackingEvent = RecoverSafeTrackingEvent.feeIntro
        push(controller)
    }

}

extension RecoverSafeFlowCoordinator: OnboardingIntroViewControllerDelegate {

    func didPressNext() {
        push(addressViewController())
    }

    func didGoBack() {
        finish()
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

extension RecoverSafeFlowCoordinator: TwoFATableViewControllerDelegate {

    func didSelectTwoFAOption(_ option: TwoFAOption) {
        switch option {
        case .statusKeycard:
            keycardFlowCoordinator.mainFlowCoordinator = mainFlowCoordinator
            keycardFlowCoordinator.hidesSteps = true
            keycardFlowCoordinator.onSucces = { address in
                ApplicationServiceRegistry.walletService.addOwner(address: address, type: .keycard)
            }
            enter(flow: keycardFlowCoordinator) {
                self.showPaymentIntro()
            }
        case .gnosisAuthenticator:
            showConnectAuthenticator()
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

    private func showConnectAuthenticator() {
        let controller = AuthenticatorViewController.create(delegate: self)
        push(controller)
    }

}

extension RecoverSafeFlowCoordinator: AuthenticatorViewControllerDelegate {

    func authenticatorViewController(_ controller: AuthenticatorViewController, didScanAddress address: String, code: String) throws {
        try ApplicationServiceRegistry.walletService
            .addBrowserExtensionOwner(address: address, browserExtensionCode: code)
    }

    func authenticatorViewControllerDidFinish() {
        showPaymentIntro()
    }

    func didSelectOpenAuthenticatorInfo() {
        SupportFlowCoordinator(from: self).openAuthenticatorInfo()
    }

    func authenticatorViewControllerDidSkipPairing() {
        ApplicationServiceRegistry.walletService.removeBrowserExtensionOwner()
        showPaymentIntro()
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
        let controller = OnboardingPaymentMethodViewController.create(delegate: self, estimations: estimations)
        controller.descriptionText = LocalizedString("choose_how_to_pay_recovery_fee",
                                                     comment: "Recovery payment method description")
        controller.screenTrackingEvent = RecoverSafeTrackingEvent.paymentMethod
        push(controller)
    }

    func creationFeeIntroPay() {
        push(RecoverRecoveryFeeViewController.create(delegate: self))
    }

}

extension RecoverSafeFlowCoordinator: CreationFeePaymentMethodDelegate {

    func creationFeePaymentMethodPay() {
        creationFeeIntroPay()
    }

    func creationFeePaymentMethodLoadEstimates() -> [TokenData] {
        let estimates = creationFeeLoadEstimates()
        // hacky: we want to update the payment intro at this point as well.
        // TODO: duplicate code.
        DispatchQueue.main.async {
            if let controller = self.navigationController.viewControllers.first(where: {
                $0 is OnboardingCreationFeeIntroViewController }) as? OnboardingCreationFeeIntroViewController {
                controller.update(with: estimates)
            }
        }
        return estimates
    }

}

extension RecoverSafeFlowCoordinator: RecoverRecoveryFeeViewControllerDelegate {

    func recoverRecoveryFeeViewControllerDidBecomeReadyToSubmit(_ controller: RecoverRecoveryFeeViewController) {
        guard let walletID = ApplicationServiceRegistry.walletService.selectedWalletID(),
            let tx = ApplicationServiceRegistry.recoveryService.recoveryTransaction(walletID: walletID) else { return }
        let controller = RecoverReviewViewController(transactionID: tx.id, delegate: self)
        controller.screenTrackingEvent = RecoverSafeTrackingEvent.review
        var stack = navigationController.viewControllers
        stack.removeLast()
        stack.append(controller)
        navigationController.viewControllers = stack
    }

    func recoverRecoveryFeeViewControllerDidCancel(_ controller: RecoverRecoveryFeeViewController) {
        finish(from: controller)
    }

}

extension RecoverSafeFlowCoordinator: ReviewTransactionViewControllerDelegate {

    func reviewTransactionViewControllerDidFinishReview(_ controller: ReviewTransactionViewController) {
        showInProgress()
    }

    func reviewTransactionViewControllerWantsToSubmitTransaction(_ controller: ReviewTransactionViewController,
                                                                 completion: @escaping (Bool) -> Void) {
        completion(true)
    }

}

extension RecoverSafeFlowCoordinator: RecoverFeePaidViewControllerDelegate {

    func recoverFeePaidViewControllerOpenMenu(_ controller: RecoverFeePaidViewController) {
        mainFlowCoordinator.openMenu()
    }

    func recoverFeePaidViewControllerWantsToOpenTransactionInExternalViewer(_ controller: RecoverFeePaidViewController,
                                                                            transactionID: String) {
        SupportFlowCoordinator(from: self).openTransactionBrowser(transactionID)
    }

    func recoverFeePaidViewControllerDidFail(_ controller: RecoverFeePaidViewController) {
        finish(from: controller)
    }

    func recoverFeePaidViewControllerDidSuccess(_ controller: RecoverFeePaidViewController) {
        finish(from: controller)
    }

}
