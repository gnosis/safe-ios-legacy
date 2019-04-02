//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import IdentityAccessApplication

class VerifyCurrentPasswordViewControllerTests: XCTestCase {

    var vc: VerifyCurrentPasswordViewController!
    let authenticationService = MockAuthenticationService()
    // swiftling disable:next weak_delegate
    let verifyDelegate = MockVerifyCurrentPasswordViewControllerDelegate()

    override func setUp() {
        super.setUp()
        IdentityAccessApplication.ApplicationServiceRegistry.put(service: authenticationService,
                                                                 for: AuthenticationApplicationService.self)
        vc = VerifyCurrentPasswordViewController.create(delegate: verifyDelegate)
        vc.loadViewIfNeeded()
    }

    func test_whenCreated_hasAllElements() {
        XCTAssertNotNil(vc.passwordInput)
        XCTAssertNotNil(vc.tryAgainInLabel)
        XCTAssertNotNil(vc.countdownStack)
    }

    func test_whenPasswordInputEntered_thenRequestsAuthentication() {
        hitReturn()
        XCTAssertTrue(authenticationService.didRequestPasswordAuthentication)
    }

}

extension VerifyCurrentPasswordViewControllerTests {

    private func hitReturn() {
        vc.verifiableInputDidReturn(vc.passwordInput)
    }

}

class MockVerifyCurrentPasswordViewControllerDelegate: VerifyCurrentPasswordViewControllerDelegate {

    var didVerify = false
    func didVerifyPassword() {
        didVerify = true
    }

}
