//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import CommonTestSupport
import Common
import MultisigWalletApplication

class SafeCreationViewControllerTests: SafeTestCase {

    //swiftlint:disable:next weak_delegate
    var delegate = MockPendingSafeViewControllerDelegate()
    var controller: SafeCreationViewController!

    override func setUp() {
        super.setUp()
        controller = SafeCreationViewController.create(delegate: delegate)
    }

    func test_canCreate() {
        controller.loadViewIfNeeded()
        XCTAssertNotNil(controller)
        XCTAssertNotNil(controller.cancelButton)
        XCTAssertNotNil(controller.progressView)
        XCTAssertNotNil(controller.progressStatusLabel)
        XCTAssertNotNil(controller.headerLabel)
        XCTAssertTrue(controller.cancelButton.isEnabled)
    }

    func test_tracking() {
        XCTAssertTracksAppearance(in: controller, OnboardingTrackingEvent.creationFee)
    }

    // TODO: re-enable
//    func test_whenStateChanges_thenUpdatesControls() {
//        class MyState: PendingSafeViewController.State {
//            override var canCancel: Bool { return true }
//            override var canRetry: Bool { return true }
//            override var canCopyAddress: Bool { return true }
//            override var isFinalState: Bool { return true }
//            override var addressText: String? { return "address" }
//            override var statusText: String? { return "status" }
//            override var progress: Double { return 0.7 }
//        }
//        loadController()
//        controller.state = MyState()
//        XCTAssertTrue(controller.cancelButton.isEnabled)
//        XCTAssertTrue(controller.retryButton.isEnabled)
//        XCTAssertFalse(controller.copySafeAddressButton.isHidden)
//        XCTAssertEqual(delegate.success, true)
//        XCTAssertEqual(controller.safeAddressLabel.text, "address")
//        XCTAssertEqual(controller.progressStatusLabel.text, "status")
//        XCTAssertEqual(controller.progressView.progress, 0.7)
//    }
//
//    func test_whenNotified_thenFetchesState() {
//        walletService.expect_deployWallet(subscriber: controller)
//        loadController()
//        walletService.expect_walletState(.deploying)
//        controller.notify()
//        delay()
//        XCTAssertTrue(walletService.verify())
//        XCTAssertTrue(controller.state === controller.deployingState)
//    }
//
//    func test_whenCancels_thenCallsDelegate() {
//        controller.cancel(controller)
//        XCTAssertTrue(delegate.cancelled)
//    }
//
//    func test_whenRetrying_thenDeploysAgain() {
//        walletService.expect_deployWallet(subscriber: controller)
//        walletService.expect_deployWallet(subscriber: controller)
//        loadController()
//        controller.retryDeployment(controller)
//        delay()
//        XCTAssertTrue(walletService.verify())
//    }
//
//    func test_whenStateChangesBeforeViewLoading_thenHarmless() {
//        controller.state = controller.nilState
//    }
//
//    func test_whenCopyingAddress_thenCopiesToPasteboard() {
//        walletService.assignAddress("some")
//        controller.copySafeAddress(controller)
//        XCTAssertEqual(UIPasteboard.general.string, "some")
//    }
//
//    func test_whenDeploymentThrowsNetworkError_thenShowsAlert() {
//        assertAlertOnError(WalletApplicationServiceError.networkError)
//        assertAlertOnError(WalletApplicationServiceError.clientError)
//        assertAlertOnError(EthereumApplicationService.Error.networkError)
//        assertAlertOnError(EthereumApplicationService.Error.clientError)
//        assertAlertOnError(NSError(domain: NSURLErrorDomain, code: 1, userInfo: nil))
//        XCTAssertTrue(controller.state === controller.errorState)
//    }
//
//    func test_whenDeploymentThrowsNonNetworkError_thenNotifiesDelegate() {
//        walletService.expect_deployWallet_throw(TestError.error)
//        loadController()
//        XCTAssertEqual(delegate.success, false)
//    }
//
//    func test_whenStateChanges_thenAppropriateTextAndProgress() {
//        loadController()
//        XCTAssertNil(controller.state(from: .draft).addressText)
//    }
//
//    func test_whenStateNotEnoughFunds_thenHasCorrectContent() {
//        loadController()
//
//        let state = controller.state(from: .notEnoughFunds)
//        walletService.assignAddress("address123")
//        walletService.updateMinimumFunding(account: ethID, amount: 1)
//        walletService.update(account: ethID, newBalance: 2)
//
//        let status = state.statusText
//        XCTAssertEqual(status?.contains("1"), true)
//        XCTAssertEqual(status?.contains("2"), true)
//        let address = state.addressText
//        XCTAssertEqual(address?.contains("address123"), true)
//
//        XCTAssertTrue(state.canCancel)
//        XCTAssertTrue(state.canCopyAddress)
//    }
//
//    func test_whenOtherStates_thenChangesStatus() {
//        loadController()
//        XCTAssertNotNil(controller.state(from: .creationStarted).statusText)
//        XCTAssertNotNil(controller.state(from: .finalizingDeployment).statusText)
//        XCTAssertNotNil(controller.state(from: .readyToUse).statusText)
//        XCTAssertTrue(controller.state(from: .readyToUse).isFinalState)
//    }
//
//    func test_whenStatesAreChanged_thenProgressIncreases() {
//        loadController()
//        let progresses = [controller.nilState, controller.errorState, controller.deployingState,
//                          controller.notEnoughFundsState, controller.creationStartedState,
//                          controller.finalizingDeploymentState, controller.readyToUseState]
//            .map { $0!.progress }
//
//        stride(from: 0, to: progresses.count - 1, by: 2).forEach {
//            XCTAssertGreaterThanOrEqual(progresses[$0 + 1], progresses[$0])
//        }
//    }

}

extension SafeCreationViewControllerTests {

    private func loadController() {
        controller.loadViewIfNeeded()
        delay()
    }

    private func assertAlertOnError(_ error: Swift.Error, file: StaticString = #file, line: UInt = #line) {
        walletService.expect_deployWallet_throw(error)
        controller = SafeCreationViewController.create(delegate: delegate)
        createWindow(controller)
        XCTAssertAlertShown(file: file, line: line)
    }

}

class MockPendingSafeViewControllerDelegate: SafeCreationViewControllerDelegate {

    var success: Bool?
    var cancelled = false

    func deploymentDidFail(_ message: String) {
        success = false
    }

    func deploymentDidSuccess() {
        success = true
    }

    func deploymentDidCancel() {
        cancelled = true
    }

}
