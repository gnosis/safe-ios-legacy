//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import CommonTestSupport
import Common
import MultisigWalletApplication

class NewSafeFlowCoordinatorTests: SafeTestCase {

    var newSafeFlowCoordinator: NewSafeFlowCoordinator!
    let nav = UINavigationController()
    var startVC: UIViewController!
    let address = "test_address"

    var topViewController: UIViewController? {
        return newSafeFlowCoordinator.navigationController.topViewController
    }

    override func setUp() {
        super.setUp()
        newSafeFlowCoordinator = NewSafeFlowCoordinator(rootViewController: UINavigationController())
        newSafeFlowCoordinator.setUp()
    }

    func test_startViewController_returnsSetupSafeStartVC() {
        XCTAssertTrue(topViewController is NewSafeViewController)
    }

    func test_didSelectBrowserExtensionSetup_showsController() {
        newSafeFlowCoordinator.didSelectBrowserExtensionSetup()
        delay()
        XCTAssertTrue(topViewController is PairWithBrowserExtensionViewController)
    }

    func test_pairWithBrowserExtensionCompletion_popsToStartVC() {
        walletService.expect_isSafeCreationInProgress(true)
        let startVC = topViewController
        newSafeFlowCoordinator.didSelectBrowserExtensionSetup()
        delay()
        let pairVC = topViewController as? PairWithBrowserExtensionViewController
        pairVC?.pairCompletion()
        delay()
        XCTAssertTrue(topViewController === startVC)
    }

    func test_whenSelectedPaperWalletSetup_thenTransitionsToPaperWalletCoordinator() {
        let testFC = TestFlowCoordinator()
        testFC.enter(flow: PaperWalletFlowCoordinator())
        let expectedViewController = testFC.topViewController

        newSafeFlowCoordinator.didSelectPaperWalletSetup()

        let finalTransitionedViewController = newSafeFlowCoordinator.navigationController.topViewController
        XCTAssertTrue(type(of: finalTransitionedViewController) == type(of: expectedViewController))
    }

    func test_didSelectNext_presentsNextController() {
        newSafeFlowCoordinator.didSelectNext()
        delay()
        XCTAssertTrue(topViewController is SafeCreationViewController)
    }

    func test_paperWalletSetupCompletion_popsToStartVC() {
        let startVC = topViewController
        newSafeFlowCoordinator.didSelectPaperWalletSetup()
        delay()
        newSafeFlowCoordinator.paperWalletFlowCoordinator.didConfirm()
        delay()
        XCTAssertTrue(topViewController === startVC)
    }

    func test_whenCancellationAlertConfirmed_thenPopsBackToNewSafeScreen() {
        walletService.createReadyToDeployWallet()
        walletService.expect_deployWallet()
        createWindow(newSafeFlowCoordinator.rootViewController)
        newSafeFlowCoordinator.didSelectNext()
        delay(1)
        newSafeFlowCoordinator.deploymentDidCancel()
        delay(1)
        let alert = newSafeFlowCoordinator.rootViewController.presentedViewController as! UIAlertController
        guard let confirmCancellationAction = alert.actions.first(where: { $0.style == .destructive }) else {
            XCTFail("Confirm cancellation action not found")
            return
        }
        walletService.expect_abortDeployment()
        confirmCancellationAction.test_handler?(confirmCancellationAction)
        delay(1)
        XCTAssertTrue(walletService.verify())
        XCTAssertNil(newSafeFlowCoordinator.rootViewController.presentedViewController)
        XCTAssertTrue(newSafeFlowCoordinator.navigationController.topViewController is NewSafeViewController)
    }

    func test_whenCancellationAlertDismissed_thenStaysOnPendingController() {
        walletService.createReadyToDeployWallet()
        createWindow(newSafeFlowCoordinator.rootViewController)
        newSafeFlowCoordinator.didSelectNext()
        delay(1)
        newSafeFlowCoordinator.deploymentDidCancel()
        delay(1)
        let alert = newSafeFlowCoordinator.rootViewController.presentedViewController as! UIAlertController
        guard let action = alert.actions.first(where: { $0.style == .cancel }) else {
            XCTFail("Confirm cancellation action not found")
            return
        }
        action.test_handler?(action)
        delay(1)
        XCTAssertNil(newSafeFlowCoordinator.rootViewController.presentedViewController)
        XCTAssertTrue(newSafeFlowCoordinator.navigationController.topViewController is SafeCreationViewController)
    }

    func test_whenDeploymentSuccess_thenExitsFlow() {
        let testFC = TestFlowCoordinator()
        var finished = false
        testFC.enter(flow: newSafeFlowCoordinator) {
            finished = true
        }
        newSafeFlowCoordinator.deploymentDidSuccess()
        XCTAssertTrue(finished)
    }

    func test_whenDeploymentFailed_thenShowsAlertThatTakesBackToNewSafeScreen() {
        walletService.createReadyToDeployWallet()
        createWindow(newSafeFlowCoordinator.rootViewController)
        newSafeFlowCoordinator.didSelectNext()
        delay(1)
        newSafeFlowCoordinator.deploymentDidFail("")
        delay(1)
        guard let alert = newSafeFlowCoordinator.rootViewController.presentedViewController as? UIAlertController,
            let action = alert.actions.first(where: { $0.style == .cancel }) else {
                XCTFail("Confirm cancellation action not found")
                return
        }
        action.test_handler?(action)
        delay(1)
        XCTAssertNil(newSafeFlowCoordinator.rootViewController.presentedViewController)
        XCTAssertTrue(newSafeFlowCoordinator.navigationController.topViewController is NewSafeViewController)
    }

    func test_whenSafeIsInAnyPendingState_thenShowingPendingController() {
        walletService.expect_isSafeCreationInProgress(true)
        assertShowingPendingVC()

        walletService.expect_isSafeCreationInProgress(false)
        assertShowingPendingVC(shouldShow: false)
    }

}

class MockEventSubscriber: EventSubscriber {
    func notify() {}
}

extension NewSafeFlowCoordinatorTests {

    private func deploy() {
        walletService.deployWallet(subscriber: MockEventSubscriber(), onError: nil)
    }

    private func assertShowingPendingVC(shouldShow: Bool = true, line: UInt = #line) {
        let testFC = TestFlowCoordinator()
        testFC.enter(flow: newSafeFlowCoordinator)
        delay()
        XCTAssertTrue((testFC.topViewController is SafeCreationViewController) == shouldShow,
                      "\(String(describing: testFC.topViewController)) is not PendingViewController",
                      line: line)
    }

}
