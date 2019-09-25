//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication
import Common

class CreateSafeFlowCoordinator: FlowCoordinator {

    var paperWalletFlowCoordinator = PaperWalletFlowCoordinator()
    weak var mainFlowCoordinator: MainFlowCoordinator!
    weak var onboardingController: OnboardingViewController?
    var keycardFlowCoordinator = SKKeycardFlowCoordinator()

    override func setUp() {
        super.setUp()
        let state = ApplicationServiceRegistry.walletService.walletState()!
        switch state {
        case .draft:
            showOnboarding()
        case .deploying, .waitingForFirstDeposit, .notEnoughFunds:
            creationFeeIntroPay()
        case .creationStarted, .transactionHashIsKnown, .finalizingDeployment:
            deploymentDidStart()
        case .readyToUse:
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
        vc.onBack = finish
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
        let pairingState = paired ? ThreeStepsView.State.backup_paired : .backup_notPaired
        let controller = SeedIntroViewController.create(state: pairingState) { [unowned self] in
            self.showSeed(paired: paired)
        }
        self.push(controller)
    }

    func showSeed(paired: Bool) {
        enter(flow: paperWalletFlowCoordinator) { [unowned self] in
            let pairingState = paired ? ThreeStepsView.State.backupDone_paired : .backupDone_notPaired
            let controller = SeedSuccessViewController.create(state: pairingState, onNext: self.showPayment)
            self.push(controller)
        }
    }

    func showPayment() {
        let controller = OnboardingCreationFeeIntroViewController.create(delegate: self)
        controller.titleText = LocalizedString("create_safe_title", comment: "Create Safe")
        controller.screenTrackingEvent = OnboardingTrackingEvent.createSafeFeeIntro
        push(controller)
    }

    func finish() {
        ApplicationServiceRegistry.walletService.cleanUpDrafts()
        exitFlow()
    }
}

extension CreateSafeFlowCoordinator: TwoFATableViewControllerDelegate {

    func didSelectTwoFAOption(_ option: TwoFAOption) {
        switch option {
        case .statusKeycard:
            // TODO: remove coupling - keycardFlowCoordinator should not depend on mainFlowCoordinator
            keycardFlowCoordinator.mainFlowCoordinator = mainFlowCoordinator
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

    func creationFeeIntroPay() {
        push(OnboardingCreationFeeViewController.create(delegate: self))
    }

}

extension CreateSafeFlowCoordinator: CreationFeePaymentMethodDelegate {

    func creationFeePaymentMethodPay() {
        creationFeeIntroPay()
    }

    func creationFeePaymentMethodLoadEstimates() -> [TokenData] {
        let estimates = creationFeeLoadEstimates()
        // hacky: we want to update the payment intro at this point as well.
        DispatchQueue.main.async {
            if let controller = self.navigationController.viewControllers.first(where: {
                $0 is OnboardingCreationFeeIntroViewController }) as? OnboardingCreationFeeIntroViewController {
                controller.update(with: estimates)
            }
        }
        return estimates
    }

}

extension CreateSafeFlowCoordinator: OnboardingCreationFeeViewControllerDelegate {

    func deploymentDidFail() {
        finish()
    }

    func deploymentDidStart() {
        push(OnboardingFeePaidViewController.create(delegate: self))
    }

    func deploymentDidCancel() {
        finish()
    }

    func onboardingCreationFeeOpenMenu() {
        mainFlowCoordinator.openMenu()
    }

}

extension CreateSafeFlowCoordinator: OnboardingFeePaidViewControllerDelegate {

    func onboardingFeePaidDidFail() {
        finish()
    }

    func onboardingFeePaidDidSuccess() {
        finish()
    }

    func onboardingFeePaidOpenMenu() {
        mainFlowCoordinator.openMenu()
    }

}

fileprivate extension OnboardingViewController {

    static func create(next: @escaping () -> Void,
                       finish: @escaping () -> Void) -> OnboardingViewController {
        let nextActionTitle = LocalizedString("next", comment: "Next")
        var steps = [OnboardingStepInfo]()
        steps.append(.init(image: Asset.CreateSafe.whatIsSafe.image,
                           title: LocalizedString("what_is_the_gnosis_safe", comment: "New Safe onboarding 1 title"),
                           description: LocalizedString("your_safe_is_a_smart_contract",
                                                        comment: "New Safe onboarding 1 description"),
                           actionTitle: nextActionTitle,
                           trackingEvent: CreateSafeTrackingEvent.onboarding1,
                           action: next))
        steps.append(.init(image: Asset.ContractUpgrade.upgrade1.image,
                           title: LocalizedString("secure_by_design", comment: "New Safe onboarding 2 title"),
                           description: LocalizedString("while_our_code_is_always_audited",
                                                        comment: "New Safe onboarding 2 description"),
                           actionTitle: nextActionTitle,
                           trackingEvent:  CreateSafeTrackingEvent.onboarding2,
                           action: next))
        steps.append(.init(image: Asset.CreateSafe.cryptoWithoutHassle.image,
                           title: LocalizedString("crypto_without_the_hassle", comment: "New Safe onboarding 3 title"),
                           description: LocalizedString("with_walletconnect_you_can_connect",
                                                        comment: "New Safe onboarding 3 description"),
                           actionTitle: nextActionTitle,
                           trackingEvent:  CreateSafeTrackingEvent.onboarding3,
                           action: next))
        steps.append(.init(image: Asset.CreateSafe.youAreInControl.image,
                           title: LocalizedString("you_are_in_control", comment: "New Safe onboarding 4 title"),
                           description: LocalizedString("your_funds_are_held_securely",
                                                        comment: "New Safe onboarding 4 description"),
                           actionTitle: LocalizedString("get_started", comment: "Start button title"),
                           trackingEvent:  CreateSafeTrackingEvent.onboarding4,
                           action: finish))
        return .create(steps: steps)
    }

}
