//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication
import Common

class NewSafeFlowCoordinator: FlowCoordinator {

    var paperWalletFlowCoordinator = PaperWalletFlowCoordinator()
    var pairController: PairWithBrowserExtensionViewController?

    var isSafeCreationInProgress: Bool {
        return ApplicationServiceRegistry.walletService.isSafeCreationInProgress
    }

    override func setUp() {
        super.setUp()
        if ApplicationServiceRegistry.walletService.hasReadyToUseWallet {
            exitFlow()
            return
        }
        push(GuidelinesViewController.createNewSafeGuidelines(delegate: self))
        saveCheckpoint()
        if ApplicationServiceRegistry.walletService.isSafeCreationInProgress {
            push(NewSafeViewController.create(delegate: self))
            push(SafeCreationViewController.create(delegate: self))
        }
    }

}

extension NewSafeFlowCoordinator {

    func enterAndComeBack(from coordinator: FlowCoordinator) {
        saveCheckpoint()
        enter(flow: coordinator) {
            self.popToLastCheckpoint()
        }
    }

}

extension NewSafeFlowCoordinator: GuidelinesViewControllerDelegate {

    func didPressNext() {
        push(NewSafeViewController.create(delegate: self))
    }

}

extension NewSafeFlowCoordinator: NewSafeDelegate {

    func didSelectPaperWalletSetup() {
        enterAndComeBack(from: paperWalletFlowCoordinator)
    }

    func didSelectBrowserExtensionSetup() {
        pairController = newPairController()
        push(pairController!)
    }

    func newPairController() -> PairWithBrowserExtensionViewController {
        let controller = PairWithBrowserExtensionViewController.create(delegate: self)
        controller.screenTitle = LocalizedString("browser_extension",
                                                 comment: "Title for add browser extension screen")
        controller.screenHeader = LocalizedString("ios_connect_browser_extension",
                                                  comment: "Header for add browser extension screen")
        controller.descriptionText = LocalizedString("enable_2fa",
                                                     comment: "Description for add browser extension screen")
        controller.screenTrackingEvent = OnboardingTrackingEvent.twoFA
        controller.scanTrackingEvent = OnboardingTrackingEvent.twoFAScan
        return controller
    }

    func didSelectNext() {
        push(OnboardingCreationFeeIntroViewController.create(delegate: self))
    }

}

extension NewSafeFlowCoordinator: CreationFeeIntroDelegate {

    func creationFeeIntroPay() {
        push(SafeCreationViewController.create(delegate: self))
    }

    func creationFeeIntroChangePaymentMethod(estimations: [TokenData]) {
        push(OnboardingPaymentMethodViewController.create(delegate: self, estimations: estimations))
    }

}

extension NewSafeFlowCoordinator: CreationFeePaymentMethodDelegate {

    func creationFeePaymentMethodPay() {
        creationFeeIntroPay()
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
        pop()
    }

    func pairWithBrowserExtensionViewControllerDidSkipPairing() {
        ApplicationServiceRegistry.walletService.removeBrowserExtensionOwner()
        self.pop()
    }

}

extension NewSafeFlowCoordinator: SafeCreationViewControllerDelegate {

    func deploymentDidFail(_ error: String) {
        let controller = SafeCreationFailedAlertController.create(localizedErrorDescription: error) { [unowned self] in
            self.dismissModal()
            self.popToLastCheckpoint()
        }
        presentModally(controller)
    }

    func deploymentDidSuccess() {
        exitFlow()
    }

    func deploymentDidCancel() {
        let controller = AbortSafeCreationAlertController.create(abort: { [unowned self] in
            self.dismissModal()
            self.popToLastCheckpoint()
        }, continue: { [unowned self] in
            self.dismissModal()
        })
        presentModally(controller)
    }

}
