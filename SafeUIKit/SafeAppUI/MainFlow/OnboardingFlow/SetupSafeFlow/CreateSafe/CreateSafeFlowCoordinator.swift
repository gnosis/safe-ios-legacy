//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication
import Common

class CreateSafeFlowCoordinator: FlowCoordinator {

    var paperWalletFlowCoordinator = PaperWalletFlowCoordinator()
    weak var mainFlowCoordinator: MainFlowCoordinator!

    override func setUp() {
        super.setUp()
        let state = ApplicationServiceRegistry.walletService.walletState()!
        switch state {
        case .draft:
            push(OnboardingIntroViewController.createCreateSafeIntro(delegate: self))
        case .deploying, .waitingForFirstDeposit, .notEnoughFunds:
            creationFeeIntroPay()
        case .creationStarted, .transactionHashIsKnown, .finalizingDeployment:
            deploymentDidStart()
        case .readyToUse:
            exitFlow()
        }
    }

}

extension CreateSafeFlowCoordinator: OnboardingIntroViewControllerDelegate {

    func didPressNext() {
        let controller = TwoFAViewController.create(delegate: self)
        controller.screenTitle = LocalizedString("browser_extension",
                                                 comment: "Title for add browser extension screen")
        controller.screenHeader = LocalizedString("ios_connect_browser_extension",
                                                  comment: "Header for add browser extension screen")
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
