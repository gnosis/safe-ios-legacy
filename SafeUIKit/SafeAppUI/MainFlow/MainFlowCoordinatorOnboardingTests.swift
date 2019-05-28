//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import CommonTestSupport
import SafariServices
import MultisigWalletApplication

class MainFlowCoordinatorOnboardingTests: SafeTestCase {

    var flowCoordinator: MainFlowCoordinator!

    override func setUp() {
        super.setUp()
        flowCoordinator = MainFlowCoordinator()
    }

    func test_whenUserNotRegistered_thenShowsStartScreen() {
        authenticationService.unregisterUser()
        flowCoordinator.setUp()
        XCTAssertTrue(flowCoordinator.navigationController.topViewController is OnboardingWelcomeViewController)
    }

    func test_whenStartingSetupPassword_thenShowsTermsScreen() {
        pressSetupPasswordButton()
        XCTAssertTrue(flowCoordinator.rootViewController.presentedViewController is OnboardingTermsViewController)
    }

    private func pressSetupPasswordButton() {
        authenticationService.unregisterUser()
        flowCoordinator.setUp()
        createWindow(flowCoordinator.rootViewController)
        flowCoordinator.didStart()
        delay(0.25)
    }

    func test_whenAgreesToTerms_thenDismissesTermsAndEntersMasterPasswordFlow() {
        pressSetupPasswordButton()
        flowCoordinator.didAgree()
        delay(1.25)
        XCTAssertTrue(flowCoordinator.navigationController.topViewController is PasswordViewController)
    }

    func test_whenDisagreesToTerms_thenDismissesTerms() {
        pressSetupPasswordButton()
        flowCoordinator.didDisagree()
        delay(1.0)
        XCTAssertTrue(flowCoordinator.navigationController.topViewController is OnboardingWelcomeViewController)
        XCTAssertNil(flowCoordinator.rootViewController.presentedViewController)
    }

    func test_whenOpensTermsOfUse_thenOpensSafari() {
        var config = WalletApplicationServiceConfiguration.default
        config.termsOfUseURL = URL(string: "https://gnosis.pm/")!
        reconfigureService(with: config)
        pressSetupPasswordButton()
        flowCoordinator.wantsToOpenTermsOfUse()
        delay(1.0)
        XCTAssertTrue(flowCoordinator.rootViewController.presentedViewController?
            .presentedViewController is SFSafariViewController)
    }

    func test_whenOpensPrivacyPolicy_thenOpensSafari() {
        var config = WalletApplicationServiceConfiguration.default
        config.privacyPolicyURL = URL(string: "https://gnosis.pm/")!
        reconfigureService(with: config)
        pressSetupPasswordButton()
        flowCoordinator.wantsToOpenPrivacyPolicy()
        delay(1.0)
        XCTAssertTrue(flowCoordinator.rootViewController.presentedViewController?
            .presentedViewController is SFSafariViewController)
    }

    func test_whenDidConfirmPassword_thenSetupSafeIsShown() {
        let service = MockWalletApplicationService()
        ApplicationServiceRegistry.put(service: service, for: WalletApplicationService.self)
        service.expect_isWalletDeployable(false)
        service.expect_isSafeCreationInProgress(false)
        pressSetupPasswordButton()
        flowCoordinator.didAgree()
        delay(1.25)
        flowCoordinator.masterPasswordFlowCoordinator.didConfirmPassword()
        delay(0.5)
        XCTAssertTrue(flowCoordinator.navigationController.topViewController is OnboardingCreateOrRestoreViewController)
    }

}
