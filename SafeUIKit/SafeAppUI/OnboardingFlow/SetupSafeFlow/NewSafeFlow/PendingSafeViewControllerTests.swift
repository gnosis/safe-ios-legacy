//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import CommonTestSupport

class PendingSafeViewControllerTests: SafeTestCase {

    //swiftlint:disable:next weak_delegate
    var delegate = MockPendingSafeViewControllerDelegate()
    var controller: PendingSafeViewController!

    override func setUp() {
        super.setUp()
        controller = PendingSafeViewController.create(delegate: delegate)
    }

    func test_canCreate() {
        controller.loadViewIfNeeded()
        XCTAssertNotNil(controller)
        XCTAssertNotNil(controller.progressView)
        XCTAssertNotNil(controller.progressStatusLabel)
        XCTAssertNotNil(controller.cancelButton)
        XCTAssertNotNil(controller.titleLabel)
        XCTAssertNotNil(controller.infoLabel)
        XCTAssertNotNil(controller.safeAddressLabel)
        XCTAssertTrue(controller.cancelButton.isEnabled)
    }

    func test_whenAddressNotKnown_thenDisplaysStatus() {
        loadController()
        walletService.startDeployment()
        assert(progress: 10, status: "pending_safe.status.deployment_started")
    }

    func test_whenAddressKnown_thenDisplaysStatus() {
        loadController()
        walletService.assignAddress("address")
        delay()
        assert(progress: 20, status: "pending_safe.status.address_known")
        XCTAssertTrue(controller.cancelButton.isEnabled)
    }

    func test_whenWalletReceivedEnoughFunds_thenDisplaysStatus() {
        loadController()
        walletService.updateMinimumFunding(account: "ETH", amount: 100)
        walletService.update(account: "ETH", newBalance: 100)
        delay()
        assert(progress: 50, status: "pending_safe.status.account_funded")
        XCTAssertFalse(controller.cancelButton.isEnabled)
    }

    func test_whenNotEnoughFunds_thenDisplaysStatus() {
        loadController()
        walletService.updateMinimumFunding(account: "ETH", amount: 100)
        walletService.update(account: "ETH", newBalance: 90)
        delay()
        let status = String(format: XCLocalizedString("pending_safe.status.not_enough_funds"), "90 Wei", "100 Wei")
        XCTAssertEqual(controller.progressView.progress, 40.0 / 100.0)
        XCTAssertEqual(controller.progressStatusLabel.text, status)
        XCTAssertTrue(controller.cancelButton.isEnabled)
    }

    func test_whenTransactionSubmitted_thenDisplaysStatus() {
        loadController()
        walletService.markDeploymentAcceptedByBlockchain()
        delay()
        assert(progress: 80, status: "pending_safe.status.deployment_accepted")
        XCTAssertFalse(controller.cancelButton.isEnabled)
    }

    func test_whenTransactionSuccess_thenDisplaysStatus() {
        loadController()
        walletService.markDeploymentSuccess()
        assertDisplayedDeploySuccessStatus()
    }

    func test_whenTransactionSuccess_thenCallsDelegate() {
        loadController()
        walletService.markDeploymentSuccess()
        delay()
        XCTAssertEqual(delegate.success, true)
    }

    func test_whenStatusUpdated_thenDisplaysIt() {
        loadController()
        walletService.markDeploymentSuccess()
        delay()
        assertDisplayedDeploySuccessStatus()
    }

    func test_whenCancels_thenCallsDelegate() {
        controller.loadViewIfNeeded()
        controller.cancel(controller)
        XCTAssertTrue(delegate.cancelled)
    }

    func test_whenShouldResumeDeployment_thenStartsDeployment() {
        controller.loadViewIfNeeded()
        delay()
        XCTAssertTrue(walletService.selectedWalletState == .deploymentStarted)
    }

}

extension PendingSafeViewControllerTests {

    private func loadController() {
        controller.loadViewIfNeeded()
        delay()
    }

    private func assert(progress percentage: Float, status key: String, line: UInt = #line) {
        XCTAssertEqual(controller.progressView.progress, percentage / 100.0, line: line)
        XCTAssertEqual(controller.progressStatusLabel.text, XCLocalizedString(key), line: line)
    }

    private func assertDisplayedDeploySuccessStatus() {
        delay()
        assert(progress: 100, status: "pending_safe.status.deployment_success")
    }

}

class MockPendingSafeViewControllerDelegate: PendingSafeViewControllerDelegate {

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
