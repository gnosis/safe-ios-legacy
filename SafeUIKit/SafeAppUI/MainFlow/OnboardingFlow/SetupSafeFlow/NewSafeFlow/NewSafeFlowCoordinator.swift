//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication
import Common

class NewSafeFlowCoordinator: FlowCoordinator {

    var paperWalletFlowCoordinator = PaperWalletFlowCoordinator()
    weak var mainFlowCoordinator: MainFlowCoordinator!

    override func setUp() {
        super.setUp()
        let state = ApplicationServiceRegistry.walletService.walletState()!
        switch state {
        case .draft:
            push(GuidelinesViewController.createNewSafeGuidelines(delegate: self))
        case .deploying, .waitingForFirstDeposit, .notEnoughFunds:
            creationFeeIntroPay()
        case .creationStarted, .transactionHashIsKnown, .finalizingDeployment:
            deploymentDidStart()
        case .readyToUse:
            exitFlow()
        }
    }

}

extension NewSafeFlowCoordinator: GuidelinesViewControllerDelegate {

    func didPressNext() {
        let controller = PairWithBrowserExtensionViewController.create(delegate: self)
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

extension NewSafeFlowCoordinator: PairWithBrowserExtensionViewControllerDelegate {

    func pairWithBrowserExtensionViewController(_ controller: PairWithBrowserExtensionViewController,
                                                didScanAddress address: String,
                                                code: String) throws {
        try ApplicationServiceRegistry.walletService
            .addBrowserExtensionOwner(address: address, browserExtensionCode: code)
    }

    func pairWithBrowserExtensionViewControllerDidFinish() {
        showSeed()
    }

    func pairWithBrowserExtensionViewControllerDidSkipPairing() {
        ApplicationServiceRegistry.walletService.removeBrowserExtensionOwner()
        showSeed()
    }

    func showSeed() {
        enter(flow: paperWalletFlowCoordinator) {
            self.showPayment()
        }
    }

    func showPayment() {
        push(OnboardingCreationFeeIntroViewController.create(delegate: self))
    }

}

extension NewSafeFlowCoordinator: CreationFeeIntroDelegate {

    func creationFeeIntroChangePaymentMethod(estimations: [TokenData]) {
        push(OnboardingPaymentMethodViewController.create(delegate: self, estimations: estimations))
    }

    func creationFeeIntroPay() {
        push(OnboardingCreationFeeViewController.create(delegate: self))
    }

}

extension NewSafeFlowCoordinator: CreationFeePaymentMethodDelegate {

    func creationFeePaymentMethodPay() {
        creationFeeIntroPay()
    }

}

extension NewSafeFlowCoordinator: OnboardingCreationFeeViewControllerDelegate {

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

extension NewSafeFlowCoordinator: OnboardingFeePaidViewControllerDelegate {

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
