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
