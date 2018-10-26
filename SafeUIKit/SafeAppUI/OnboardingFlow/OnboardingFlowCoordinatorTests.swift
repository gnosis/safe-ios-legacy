//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import CommonTestSupport
import SafariServices
import MultisigWalletApplication

class OnboardingFlowCoordinatorTests: SafeTestCase {

    var flowCoordinator: OnboardingFlowCoordinator!

    override func setUp() {
        super.setUp()
        flowCoordinator = OnboardingFlowCoordinator(rootViewController: UINavigationController())
    }

    func test_whenUserNotRegistered_thenShowsStartScreen() {
        authenticationService.unregisterUser()
        flowCoordinator.setUp()
        XCTAssertTrue(flowCoordinator.navigationController.topViewController is StartViewController)
    }

    func test_startViewController_whenNoMasterPassword_thenMasterPasswordFlowStarted() {
        let testFC = TestFlowCoordinator()
        let masterPasswordFC = MasterPasswordFlowCoordinator()
        testFC.enter(flow: masterPasswordFC)
        let expectedController = testFC.topViewController

        authenticationService.unregisterUser()
        flowCoordinator.setUp()
        flowCoordinator.didStart()

        XCTAssertNotNil(flowCoordinator.navigationController.topViewController)
        XCTAssertTrue(type(of: flowCoordinator.navigationController.topViewController) == type(of: expectedController))
    }

    func test_whenStartingSetupPassword_thenShowsTermsScreen() {
        pressSetupPasswordButton()
        XCTAssertTrue(flowCoordinator.rootViewController.presentedViewController is TermsAndConditionsViewController)
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
        XCTAssertTrue(flowCoordinator.navigationController.topViewController is StartViewController)
        XCTAssertNil(flowCoordinator.rootViewController.presentedViewController)
    }

    func test_whenOpensTermsOfUse_thenOpensSafari() {
        let service = MockWalletApplicationService()
        ApplicationServiceRegistry.put(service: service, for: WalletApplicationService.self)
        service.termsOfUseURL = URL(string: "https://gnosis.pm/")!
        pressSetupPasswordButton()
        flowCoordinator.wantsToOpenTermsOfUse()
        delay(1.0)
        XCTAssertTrue(flowCoordinator.rootViewController.presentedViewController?
            .presentedViewController is SFSafariViewController)
    }

    func test_whenOpensPrivacyPolicy_thenOpensSafari() {
        let service = MockWalletApplicationService()
        ApplicationServiceRegistry.put(service: service, for: WalletApplicationService.self)
        service.termsOfUseURL = URL(string: "https://gnosis.pm/")!
        pressSetupPasswordButton()
        flowCoordinator.wantsToOpenPrivacyPolicy()
        delay(1.0)
        XCTAssertTrue(flowCoordinator.rootViewController.presentedViewController?
            .presentedViewController is SFSafariViewController)
    }

    func test_startViewController_whenMasterPasswordIsSet_thenNewSafeFlowStarted() {
        let testFC = TestFlowCoordinator()
        let setupSafeFC = SetupSafeFlowCoordinator()
        testFC.enter(flow: setupSafeFC)
        let expectedController = testFC.topViewController

        try? authenticationService.registerUser(password: "password")
        flowCoordinator.setUp()

        XCTAssertNotNil(flowCoordinator.navigationController.topViewController)
        XCTAssertTrue(type(of: flowCoordinator.navigationController.topViewController) == type(of: expectedController))
    }

    func test_whenDidConfirmPassword_thenSetupSafeIsShown() {
        authenticationService.unregisterUser()
        walletService.expect_isWalletDeployable(false)
        flowCoordinator.setUp()
        flowCoordinator.didStart()
        delay(0.25)
        flowCoordinator.masterPasswordFlowCoordinator.didConfirmPassword()
        delay(0.25)
        let controller = flowCoordinator.navigationController.topViewController
        print(String(reflecting: controller.self))
        XCTAssertTrue(controller is SetupSafeOptionsViewController)
    }

    func test_whenSetupSafeFlowExits_thenOnboardingFlowExits() {
        try? authenticationService.registerUser(password: "password")
        let testFC = TestFlowCoordinator()
        var finished = false
        testFC.enter(flow: flowCoordinator) { finished = true }
        flowCoordinator.setupSafeFlowCoordinator.exitFlow()
        XCTAssertTrue(finished)
    }

}
