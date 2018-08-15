//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import CommonTestSupport
import Common

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
        let startVC = topViewController
        newSafeFlowCoordinator.didSelectBrowserExtensionSetup()
        delay()
        newSafeFlowCoordinator.didPair()
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
        XCTAssertTrue(topViewController is PendingSafeViewController)
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
        confirmCancellationAction.test_handler?(confirmCancellationAction)
        delay(1)
        XCTAssertEqual(walletService.selectedWalletState, .newDraft)
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
        XCTAssertTrue(newSafeFlowCoordinator.navigationController.topViewController is PendingSafeViewController)
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
        walletService.startDeployment()
        assertShowingPendingVC()

        walletService.assignAddress("address")
        assertShowingPendingVC()

        walletService.updateMinimumFunding(account: ethID, amount: 100)
        walletService.update(account: ethID, newBalance: 50)
        assertShowingPendingVC()

        walletService.update(account: ethID, newBalance: 100)
        assertShowingPendingVC()

        walletService.markDeploymentAcceptedByBlockchain()
        assertShowingPendingVC()

        walletService.createReadyToUseWallet()
        assertShowingPendingVC(shouldShow: false)
    }

    func test_whenSafeIsNotReadyToUse_thenIsNotFinishedTrue() {
        walletService.createNewDraftWallet()
        assertNotFinished()

        walletService.createReadyToDeployWallet()
        assertNotFinished()

        walletService.startDeployment()
        assertNotFinished()

        walletService.assignAddress("address")
        assertNotFinished()

        walletService.updateMinimumFunding(account: ethID, amount: 100)
        walletService.update(account: ethID, newBalance: 50)
        assertNotFinished()

        walletService.update(account: ethID, newBalance: 100)
        assertNotFinished()

        walletService.markDeploymentAcceptedByBlockchain()
        assertNotFinished()

        walletService.createReadyToUseWallet()
        assertFinished()
    }

}

extension NewSafeFlowCoordinatorTests {

    private func assertShowingPendingVC(shouldShow: Bool = true, line: UInt = #line) {
        let testFC = TestFlowCoordinator()
        testFC.enter(flow: newSafeFlowCoordinator)
        delay()
        XCTAssertTrue((testFC.topViewController is PendingSafeViewController) == shouldShow,
                      "\(String(describing: testFC.topViewController)) is not PendingViewController",
                      line: line)
    }

    private func assertNotFinished(line: UInt = #line) {
        XCTAssertTrue(newSafeFlowCoordinator.isSafeCreationInProgress, line: line)
    }

    private func assertFinished(line: UInt = #line) {
        XCTAssertFalse(newSafeFlowCoordinator.isSafeCreationInProgress, line: line)
    }

}
