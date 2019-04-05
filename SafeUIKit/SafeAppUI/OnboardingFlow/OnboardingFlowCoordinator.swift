//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import IdentityAccessApplication
import SafariServices
import MultisigWalletApplication

final class OnboardingFlowCoordinator: FlowCoordinator {

    let masterPasswordFlowCoordinator = MasterPasswordFlowCoordinator()
    let setupSafeFlowCoordinator = SetupSafeFlowCoordinator()

    private var isUserRegistered: Bool {
        return ApplicationServiceRegistry.authenticationService.isUserRegistered
    }

    override func setUp() {
        super.setUp()
        if isUserRegistered {
            enterSetupSafeFlow()
        } else {
            push(StartViewController.create(delegate: self))
        }
    }

    private func enterSetupSafeFlow() {
        enter(flow: setupSafeFlowCoordinator) { [unowned self] in
            self.exitFlow()
        }
    }

}

extension OnboardingFlowCoordinator: StartViewControllerDelegate {

    func didStart() {
        let controller = TermsAndConditionsViewController.create()
        controller.delegate = self
        controller.modalPresentationStyle = .overFullScreen
        rootViewController.definesPresentationContext = true
        presentModally(controller)
    }

}

extension OnboardingFlowCoordinator: TermsAndConditionsViewControllerDelegate {

    func wantsToOpenTermsOfUse() {
        SupportFlowCoordinator(from: self).openTermsOfUse()
    }

    func wantsToOpenPrivacyPolicy() {
        SupportFlowCoordinator(from: self).openPrivacyPolicy()
    }

    func didDisagree() {
        dismissModal()
    }

    func didAgree() {
        dismissModal { [unowned self] in
            self.enter(flow: self.masterPasswordFlowCoordinator) {
                self.clearNavigationStack()
                self.enterSetupSafeFlow()
            }
        }
    }

}
