//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication
import Common

class CreateSafeFlowCoordinator: FlowCoordinator {

    weak var onboardingController: OnboardingViewController?
    var keycardFlowCoordinator = SKKeycardFlowCoordinator()

    override func setUp() {
        super.setUp()
        let state = ApplicationServiceRegistry.walletService.walletState()!
        switch state {
        case .draft:
            showOnboarding()
        case .deploying, .waitingForFirstDeposit, .notEnoughFunds:
            showCreationFee()
        case .creationStarted, .transactionHashIsKnown, .finalizingDeployment:
            showInProgress()
        case .readyToUse, .recoveryDraft, .recoveryInProgress, .recoveryPostProcessing:
            exitFlow()
        }
    }

    private func showOnboarding() {
        let vc = OnboardingViewController.create(next: { [weak self] in
            self?.onboardingController?.transitionToNextPage()
            }, finish: { [weak self] in
                Tracker.shared.track(event: OnboardingTrackingEvent.newSafeGetStarted)
                self?.showCreateSafeIntro()
            })
        vc.onBack = { [unowned self] in
            self.finish()
        }
        push(vc)
        onboardingController = vc
    }

    private func showCreateSafeIntro() {
        let controller = ThreeStepsToSecurityController.create { [unowned self] in
            self.showPairWithTwoFA()
        }
        push(controller)
    }

    private func showPairWithTwoFA() {
        let controller = PairWith2FAController.create(onNext: { [unowned self] in
            let controller = TwoFATableViewController()
            controller.delegate = self
            self.push(controller)
        }, onSkip: { [unowned self] in
            self.skipPairing()
        })
        push(controller)
    }

    private func skipPairing() {
        ApplicationServiceRegistry.walletService.removeBrowserExtensionOwner()
        showSeedIntro(paired: false)
    }

    func showSeedIntro(paired: Bool) {
        let vc = SeedFlowController()
        vc.delegate = self
        vc.isPaired = paired
        push(vc)
    }

    func showPayment() {
        let controller = OnboardingCreationFeeIntroViewController.create(delegate: self)
        controller.titleText = LocalizedString("create_safe_title", comment: "Create Safe")
        controller.screenTrackingEvent = OnboardingTrackingEvent.createSafeFeeIntro
        push(controller)
    }

    func showInProgress() {
        if let existingVC = navigationController.topViewController as? OnboardingFeePaidViewController,
            existingVC.walletID == ApplicationServiceRegistry.walletService.selectedWalletID() {
            return
        }
        let vc = OnboardingFeePaidViewController.create(delegate: self)
        setRoot(CustomNavigationController(rootViewController: vc))
    }

    func showCreationFee() {
        if let existingVC = navigationController.topViewController as? OnboardingCreationFeeViewController,
            existingVC.walletID == ApplicationServiceRegistry.walletService.selectedWalletID() { return }
        let vc = OnboardingCreationFeeViewController.create(delegate: self)
        setRoot(CustomNavigationController(rootViewController: vc))
    }

    func finish(from vc: UIViewController? = nil) {
        ApplicationServiceRegistry.walletService.cleanUpDrafts()
        if navigationController.topViewController === vc {
            MainFlowCoordinator.shared.switchToRootController()
        }
        exitFlow()
    }

    override func setRoot(_ controller: UIViewController) {
        guard rootViewController !== controller else { return }
        super.setRoot(controller)
        [keycardFlowCoordinator,
         MainFlowCoordinator.shared].forEach { $0?.setRoot(controller) }
    }

}

extension CreateSafeFlowCoordinator: SeedFlowControllerDelegate {

    func seedFlowControllerDidFinish(_ vc: SeedFlowController) {
        showPayment()
    }

}

extension CreateSafeFlowCoordinator: TwoFATableViewControllerDelegate {

    func didSelectTwoFAOption(_ option: TwoFAOption) {
        switch option {
        case .statusKeycard:
            keycardFlowCoordinator.onSucces = { address in
                ApplicationServiceRegistry.walletService.addOwner(address: address, type: .keycard)
            }
            enter(flow: keycardFlowCoordinator) {
                self.showSeedIntro(paired: true)
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

extension CreateSafeFlowCoordinator: AuthenticatorViewControllerDelegate {

    func authenticatorViewController(_ controller: AuthenticatorViewController,
                                     didScanAddress address: String,
                                     code: String) throws {
        try ApplicationServiceRegistry.walletService
            .addBrowserExtensionOwner(address: address, browserExtensionCode: code)
    }

    func authenticatorViewControllerDidFinish() {
        let controller = ConnectAuthenticatorSuccessViewController.create { [unowned self] in
            self.showSeedIntro(paired: true)
        }
        push(controller)
    }

    func didSelectOpenAuthenticatorInfo() {
        SupportFlowCoordinator(from: self).openAuthenticatorInfo()
    }

    func authenticatorViewControllerDidSkipPairing() {
        skipPairing()
    }

}

extension CreateSafeFlowCoordinator: CreationFeeIntroDelegate {

    func creationFeeIntroPay() {
        showCreationFee()
    }

    func creationFeeLoadEstimates() -> [TokenData] {
        return ApplicationServiceRegistry.walletService.estimateSafeCreation()
    }

    func creationFeeNetworkFeeAlert() -> UIAlertController {
        return .creationFee()
    }

    func creationFeeIntroChangePaymentMethod(estimations: [TokenData]) {
        let controller = OnboardingPaymentMethodViewController.create(delegate: self, estimations: estimations)
        controller.screenTrackingEvent = OnboardingTrackingEvent.createSafePaymentMethod
        push(controller)
    }

}

extension CreateSafeFlowCoordinator: CreationFeePaymentMethodDelegate {

    func creationFeePaymentMethodPay() {
        showCreationFee()
    }

    func creationFeePaymentMethodLoadEstimates() -> [TokenData] {
        let estimates = creationFeeLoadEstimates()
        // hacky: we want to update the payment intro at this point as well.
        DispatchQueue.main.async { [unowned self] in
            if let controller = self.navigationController.viewControllers.first(where: {
                $0 is OnboardingCreationFeeIntroViewController }) as? OnboardingCreationFeeIntroViewController {
                controller.update(with: estimates)
            }
        }
        return estimates
    }

}

extension CreateSafeFlowCoordinator: OnboardingCreationFeeViewControllerDelegate {

    func onboardingCreationFeeViewControllerDeploymentDidCancel(_ controller: OnboardingCreationFeeViewController) {
        finish(from: controller)
    }

    func onboardingCreationFeeViewControllerDeploymentDidStart(_ controller: OnboardingCreationFeeViewController) {
        showInProgress()
    }

    func onboardingCreationFeeViewControllerDeploymentDidFail(_ controller: OnboardingCreationFeeViewController) {
        finish(from: controller)
    }

    func onboardingCreationFeeViewControllerFeeOpenMenu(_ controller: OnboardingCreationFeeViewController) {
        MainFlowCoordinator.shared.openMenu()
    }

}

extension CreateSafeFlowCoordinator: OnboardingFeePaidViewControllerDelegate {

    func onboardingFeePaidViewControllerDidFail(_ controller: OnboardingFeePaidViewController) {
        finish(from: controller)
    }

    func onboardingFeePaidViewControllerDidSuccess(_ controller: OnboardingFeePaidViewController) {
        finish(from: controller)
    }

    func onboardingFeePaidViewControllerOpenMenu(_ controller: OnboardingFeePaidViewController) {
        MainFlowCoordinator.shared.openMenu()
    }

}

fileprivate extension OnboardingViewController {

    static func create(next: @escaping () -> Void,
                       finish: @escaping () -> Void) -> OnboardingViewController {
        let nextActionTitle = LocalizedString("next", comment: "Next")
        var steps = [OnboardingStepInfo]()
        steps.append(.init(image: Asset.whatIsSafe.image,
                           title: LocalizedString("what_is_the_gnosis_safe", comment: "New Safe onboarding 1 title"),
                           description: LocalizedString("your_safe_is_a_smart_contract",
                                                        comment: "New Safe onboarding 1 description"),
                           actionTitle: nextActionTitle,
                           trackingEvent: CreateSafeTrackingEvent.onboarding1,
                           action: next))
        steps.append(.init(image: Asset.upgrade1.image,
                           title: LocalizedString("secure_by_design", comment: "New Safe onboarding 2 title"),
                           description: LocalizedString("while_our_code_is_always_audited",
                                                        comment: "New Safe onboarding 2 description"),
                           actionTitle: nextActionTitle,
                           trackingEvent:  CreateSafeTrackingEvent.onboarding2,
                           action: next))
        steps.append(.init(image: Asset.cryptoWithoutHassle.image,
                           title: LocalizedString("crypto_without_the_hassle", comment: "New Safe onboarding 3 title"),
                           description: LocalizedString("with_walletconnect_you_can_connect",
                                                        comment: "New Safe onboarding 3 description"),
                           actionTitle: nextActionTitle,
                           trackingEvent:  CreateSafeTrackingEvent.onboarding3,
                           action: next))
        steps.append(.init(image: Asset.youAreInControl.image,
                           title: LocalizedString("you_are_in_control", comment: "New Safe onboarding 4 title"),
                           description: LocalizedString("your_funds_are_held_securely",
                                                        comment: "New Safe onboarding 4 description"),
                           actionTitle: LocalizedString("get_started", comment: "Start button title"),
                           trackingEvent:  CreateSafeTrackingEvent.onboarding4,
                           action: finish))
        return .create(steps: steps)
    }

}
