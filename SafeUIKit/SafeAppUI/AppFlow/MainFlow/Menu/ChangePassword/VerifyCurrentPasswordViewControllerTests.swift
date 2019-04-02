//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import IdentityAccessApplication
import IdentityAccessImplementations
import CommonTestSupport

class VerifyCurrentPasswordViewControllerTests: XCTestCase {

    var vc: VerifyCurrentPasswordViewController!
    let authenticationService = MockAuthenticationService()
    let clock = MockClockService()
    // swiftlint:disable:next weak_delegate
    let verifyDelegate = MockVerifyCurrentPasswordViewControllerDelegate()

    override func setUp() {
        super.setUp()
        IdentityAccessApplication.ApplicationServiceRegistry.put(service: authenticationService,
                                                                 for: AuthenticationApplicationService.self)
        IdentityAccessApplication.ApplicationServiceRegistry.put(service: clock, for: Clock.self)
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

    func test_whenAccountIsBlocked_thenShowsCountdown() throws {
        authenticationService.blockAuthentication()
        try authenticationService.configureBlockDuration(5)
        hitReturn()
        assertShowsCountdown()
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
