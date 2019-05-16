//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import IdentityAccessApplication
import IdentityAccessImplementations
import CommonTestSupport

class VerifyCurrentPasswordViewControllerTests: SafeTestCase {

    var vc: VerifyCurrentPasswordViewController!
    // swiftlint:disable:next weak_delegate
    let verifyDelegate = MockVerifyCurrentPasswordViewControllerDelegate()

    override func setUp() {
        super.setUp()
        vc = VerifyCurrentPasswordViewController.create(delegate: verifyDelegate)
        vc.loadViewIfNeeded()
    }

    func test_whenCreated_hasAllElements() {
        XCTAssertNotNil(vc.passwordInput)
        XCTAssertNotNil(vc.tryAgainInLabel)
        XCTAssertNotNil(vc.countdownStack)
        XCTAssertTrue(vc.countdownStack.isHidden)
    }

    func test_whenPasswordInputEntered_thenRequestsAuthentication() {
        hitReturn()
        XCTAssertTrue(authenticationService.didRequestPasswordAuthentication)
    }

    func test_whenPasswordPasses_thenDelegateCalled() {
        authenticationService.allowAuthentication()
        hitReturn()
        XCTAssertTrue(verifyDelegate.didVerify)
    }

    func test_whenProceeding_thenDelegareCalled() {
        authenticationService.allowAuthentication()
        vc.proceed()
        XCTAssertTrue(verifyDelegate.didVerify)
    }

    func test_whenAccountIsBlocked_thenShowsCountdown() throws {
        authenticationService.blockAuthentication()
        try authenticationService.configureBlockDuration(5)
        hitReturn()
        assertShowsCountdown()
    }

    func test_whenAuthenticatorThrows_thenErrorIsShown() {
        authenticationService.shouldThrowDuringAuthentication = true
        createWindow(vc)
        hitReturn()
        XCTAssertAlertShown()
    }

    func test_whenCountdownStops_thenPasswordEntryEnabled() {
        authenticationService.blockAuthentication()
        hitReturn()
        XCTAssertFalse(vc.countdownStack.isHidden)
        XCTAssertFalse(vc.passwordInput.isEnabled)
        clock.countdownTickBlock!(0)
        delay()
        XCTAssertTrue(vc.countdownStack.isHidden)
        XCTAssertTrue(vc.passwordInput.isEnabled)
    }

}

extension VerifyCurrentPasswordViewControllerTests {

    private func hitReturn() {
        vc.verifiableInputDidReturn(vc.passwordInput)
    }

    private func assertShowsCountdown(line: UInt = #line) {
        XCTAssertFalse(vc.countdownStack.isHidden, line: line)
        XCTAssertFalse(vc.passwordInput.isEnabled, line: line)
    }

}

class MockVerifyCurrentPasswordViewControllerDelegate: VerifyCurrentPasswordViewControllerDelegate {

    var didVerify = false
    func didVerifyPassword() {
        didVerify = true
    }

}
