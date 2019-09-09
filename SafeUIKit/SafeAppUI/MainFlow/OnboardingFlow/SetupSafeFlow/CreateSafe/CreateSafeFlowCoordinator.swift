//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication
import Common

class CreateSafeFlowCoordinator: FlowCoordinator {

    var paperWalletFlowCoordinator = PaperWalletFlowCoordinator()
    weak var mainFlowCoordinator: MainFlowCoordinator!
    weak var onboardingController: OnboardingViewController?

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
            self.push(OnboardingIntroViewController.createCreateSafeIntro(delegate: self))
        }, onSkip: { [unowned self] in
            self.push(OnboardingIntroViewController.createCreateSafeIntro(delegate: self))
        })
        push(controller)
    }

}

extension CreateSafeFlowCoordinator: OnboardingIntroViewControllerDelegate {

    func didPressNext() {
        let controller = TwoFAViewController.create(delegate: self)
        controller.screenTitle = LocalizedString("browser_extension",
                                                 comment: "Title for add browser extension screen")
        controller.screenHeader = LocalizedString("ios_connect_browser_extension",
                                                  comment: "Header for add browser extension screen")
                                  .replacingOccurrences(of: "\n", with: " ")
        controller.descriptionText = LocalizedString("enable_2fa",
                                                     comment: "Description for add browser extension screen")
        controller.screenTrackingEvent = OnboardingTrackingEvent.twoFA
        controller.scanTrackingEvent = OnboardingTrackingEvent.twoFAScan
        push(controller)
    }

}

extension CreateSafeFlowCoordinator: TwoFAViewControllerDelegate {

    func twoFAViewController(_ controller: TwoFAViewController, didScanAddress address: String, code: String) throws {
        try ApplicationServiceRegistry.walletService
            .addBrowserExtensionOwner(address: address, browserExtensionCode: code)
    }

    func twoFAViewControllerDidFinish() {
        showSeed()
    }

    func twoFAViewControllerDidSkipPairing() {
        ApplicationServiceRegistry.walletService.removeBrowserExtensionOwner()
        showSeed()
    }

    func showSeed() {
        enter(flow: paperWalletFlowCoordinator) {
            self.showPayment()
        }
    }

    func showPayment() {
        let controller = OnboardingCreationFeeIntroViewController.create(delegate: self)
        controller.titleText = LocalizedString("create_safe_title", comment: "Create Safe")
        controller.screenTrackingEvent = OnboardingTrackingEvent.createSafeFeeIntro
        push(controller)
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
        exitFlow()
    }

    func deploymentDidStart() {
        push(OnboardingFeePaidViewController.create(delegate: self))
    }

    func deploymentDidCancel() {
        exitFlow()
    }

}

extension CreateSafeFlowCoordinator: OnboardingFeePaidViewControllerDelegate {

    func onboardingFeePaidDidFail() {
        exitFlow()
    }

    func onboardingFeePaidDidSuccess() {
        exitFlow()
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
        steps.append(.init(image: Asset.ContractUpgrade.contractUpgrade.image,
                           title: LocalizedString("what_is_the_gnosis_safe", comment: "New Safe onboarding 1 title"),
                           description: LocalizedString("your_safe_is_a_smart_contract",
                                                        comment: "New Safe onboarding 1 description"),
                           actionTitle: nextActionTitle,
                           trackingEvent: OnboardingTrackingEvent.newSafeOnboarding1,
                           action: next))
        steps.append(.init(image: Asset.ContractUpgrade.upgrade1.image,
                           title: LocalizedString("secure_by_design", comment: "New Safe onboarding 2 title"),
                           description: LocalizedString("while_our_code_is_always_audited",
                                                        comment: "New Safe onboarding 2 description"),
                           actionTitle: nextActionTitle,
                           trackingEvent: OnboardingTrackingEvent.newSafeOnboarding2,
                           action: next))
        steps.append(.init(image: Asset.ConnectBrowserExtension.connectIntroIcon.image,
                           title: LocalizedString("crypto_without_the_hassle", comment: "New Safe onboarding 3 title"),
                           description: LocalizedString("with_walletconnect_you_can_connect",
                                                        comment: "New Safe onboarding 3 description"),
                           actionTitle: nextActionTitle,
                           trackingEvent: OnboardingTrackingEvent.newSafeOnboarding3,
                           action: next))
        steps.append(.init(image: Asset.ContractUpgrade.upgrade2.image,
                           title: LocalizedString("you_are_in_control", comment: "New Safe onboarding 4 title"),
                           description: LocalizedString("your_funds_are_held_securely",
                                                        comment: "New Safe onboarding 4 description"),
                           actionTitle: LocalizedString("get_started", comment: "Start button title"),
                           trackingEvent: OnboardingTrackingEvent.newSafeOnboarding4,
                           action: finish))
        return .create(steps: steps)
    }

}
