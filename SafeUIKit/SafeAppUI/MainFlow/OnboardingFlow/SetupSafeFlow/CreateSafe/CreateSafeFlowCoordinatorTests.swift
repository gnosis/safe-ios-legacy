//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import CommonTestSupport
import Common
import MultisigWalletApplication

class CreateSafeFlowCoordinatorTests: SafeTestCase {

    var newSafeFlowCoordinator: CreateSafeFlowCoordinator!

    var topViewController: UIViewController? {
        return newSafeFlowCoordinator.navigationController.topViewController
    }

    override func setUp() {
        super.setUp()
        walletService.expect_walletState(.draft)
        newSafeFlowCoordinator = CreateSafeFlowCoordinator(rootViewController: UINavigationController())
        newSafeFlowCoordinator.setUp()
    }

    func test_startViewController_returnsSetupSafeStartVC() {
        assert(topViewController, is: OnboardingIntroViewController.self)
    }

    func test_didSelectBrowserExtensionSetup_showsController() {
        newSafeFlowCoordinator.didPressNext()
        delay()
        XCTAssertTrue(topViewController is TwoFAViewController)
    }

    func test_pairWithBrowserExtensionCompletion_thenAddsBowserExtensionAndPopsToStartVC() {
        XCTAssertFalse(walletService.isOwnerExists(.browserExtension))
        pairWithBrowserExtension()
        XCTAssertTrue(walletService.isOwnerExists(.browserExtension))
        XCTAssertTrue(topViewController is SaveMnemonicViewController)
    }

    func test_whenWalletServiceThrowsDuringPairing_thenAlertIsHandled() {
        walletService.shouldThrow = true
        pairWithBrowserExtension()
        XCTAssertAlertShown(message: TwoFAViewController.Strings.invalidCode)
        assert(topViewController, is: TwoFAViewController.self)
    }

    func test_whenSelectedPaperWalletSetup_thenTransitionsToPaperWalletCoordinator() {
        let testFC = TestFlowCoordinator()
        testFC.enter(flow: PaperWalletFlowCoordinator())
        let expectedViewController = testFC.topViewController

        newSafeFlowCoordinator.showSeed()

        let finalTransitionedViewController = newSafeFlowCoordinator.navigationController.topViewController
        XCTAssertTrue(type(of: finalTransitionedViewController) == type(of: expectedViewController))
    }

    func test_didSelectNext_presentsNextController() {
        newSafeFlowCoordinator.showPayment()
        delay()
        assert(topViewController, is: OnboardingCreationFeeIntroViewController.self)
    }

    func test_didSelectCreationFeeIntroPay_presentsNextController() {
        newSafeFlowCoordinator.creationFeeIntroPay()
        delay()
        assert(topViewController, is: OnboardingCreationFeeViewController.self)
    }

    func test_didSelectCreationFeeIntroChangePaymentMethod_presentsPaymentMethodController() {
        newSafeFlowCoordinator.creationFeeIntroChangePaymentMethod(estimations: [])
        delay()
        assert(topViewController, is: OnboardingPaymentMethodViewController.self)
    }

    func test_creationFeeIntroChangePaymentMethod_presentsNextController() {
        newSafeFlowCoordinator.creationFeePaymentMethodPay()
        delay()
        assert(topViewController, is: OnboardingCreationFeeViewController.self)
    }

    func test_paperWalletSetupCompletion_showsPayment() {
        newSafeFlowCoordinator.showSeed()
        delay()
        newSafeFlowCoordinator.paperWalletFlowCoordinator.exitFlow()
        delay()
        assert(topViewController, is: OnboardingCreationFeeIntroViewController.self)
    }

    func test_whenDeploymentCancelled_thenExitsFlow() {
        walletService.expect_walletState(.creationStarted)

        let newSafeFlowCoordinator = CreateSafeFlowCoordinator(rootViewController: UINavigationController())

        let parent = MainFlowCoordinator()
        let exp = expectation(description: "Exited")
        parent.enter(flow: newSafeFlowCoordinator) {
            exp.fulfill()
        }

        newSafeFlowCoordinator.deploymentDidCancel()
        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func test_whenDeploymentSuccess_thenExitsFlow() {
        walletService.expect_walletState(.creationStarted)

        let testFC = TestFlowCoordinator()
        var finished = false
        testFC.enter(flow: newSafeFlowCoordinator) {
            finished = true
        }
        newSafeFlowCoordinator.onboardingFeePaidDidSuccess()
        XCTAssertTrue(finished)
    }

    func test_whenDeploymentFailed_thenExitsFlow() {
        walletService.expect_walletState(.creationStarted)

        let newSafeFlowCoordinator = CreateSafeFlowCoordinator(rootViewController: UINavigationController())

        let testFC = TestFlowCoordinator()
        var finished = false
        testFC.enter(flow: newSafeFlowCoordinator) {
            finished = true
        }

        newSafeFlowCoordinator.onboardingFeePaidDidFail()

        XCTAssertTrue(finished)
    }

    func test_startStates() {
        assert(when: .draft, then: OnboardingIntroViewController.self)
        assert(when: .deploying, then: OnboardingCreationFeeViewController.self)
        assert(when: .waitingForFirstDeposit, then: OnboardingCreationFeeViewController.self)
        assert(when: .notEnoughFunds, then: OnboardingCreationFeeViewController.self)
        assert(when: .creationStarted, then: OnboardingFeePaidViewController.self)
        assert(when: .creationStarted, then: OnboardingFeePaidViewController.self)
        assert(when: .finalizingDeployment, then: OnboardingFeePaidViewController.self)
    }

    func test_tracking() {
        newSafeFlowCoordinator.didPressNext()
        delay(0.5)
        let controller = newSafeFlowCoordinator.navigationController.topViewController as!
            TwoFAViewController
        let screenEvent = controller.screenTrackingEvent as? OnboardingTrackingEvent
        XCTAssertEqual(screenEvent, .twoFA)

        let scanEvent = controller.scanTrackingEvent as? OnboardingTrackingEvent
        XCTAssertEqual(scanEvent, .twoFAScan)
    }

}

private extension CreateSafeFlowCoordinatorTests {

    func assert<T>(when state: WalletStateId, then controllerClass: T.Type, line: UInt = #line) {
        walletService.expect_walletState(state)
        newSafeFlowCoordinator.setUp()
        delay()
        assert(topViewController!, is: controllerClass, line: line)
    }

    func assert<T>(_ object: Any?, is aType: T.Type, file: StaticString = #file, line: UInt = #line) {
        let message = "Expected \(T.self) but got \(String(describing: type(of: object)))"
        XCTAssertTrue(object is T, message, file: file, line: line)
    }

    func pairWithBrowserExtension() {
        ethereumService.browserExtensionAddress = "code"
        walletService.expect_isSafeCreationInProgress(true)
        newSafeFlowCoordinator.didPressNext()
        delay()
        let pairVC = topViewController as? TwoFAViewController
        pairVC!.loadViewIfNeeded()
        pairVC!.scanBarButtonItemDidScanValidCode("code")
        delay()
    }

}

class MockEventSubscriber: EventSubscriber {
    func notify() {}
}
