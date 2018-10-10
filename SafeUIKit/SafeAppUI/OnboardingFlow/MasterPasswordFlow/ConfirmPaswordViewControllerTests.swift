//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import CommonTestSupport
import IdentityAccessApplication

class ConfirmPaswordViewControllerTests: SafeTestCase {

    // swiftlint:disable:next weak_delegate
    let delegate = MockConfirmPasswordViewControllerDelegate()
    var vc: ConfirmPaswordViewController!

    override func setUp() {
        super.setUp()
        vc = ConfirmPaswordViewController.create(referencePassword: "a", delegate: delegate)
        vc.loadViewIfNeeded()
    }

    func test_whenCreated_hasAllElements() {
        XCTAssertNotNil(vc.verifiableInput)
    }

    func test_whenCreated_thenTextInputIsSecure() {
        XCTAssertTrue(vc.verifiableInput.isSecure)
    }

    func test_whenDidConfirmPassword_thenUserRegistered() {
        XCTAssertNotNil(ApplicationServiceRegistry.authenticationService)
        vc.verifiableInputDidReturn(vc.verifiableInput)
        XCTAssertTrue(authenticationService.isUserRegistered)
    }

    func test_whenRegistrationCompleted_thenCallsDelegate() {
        delegate.didConfirm = false
        vc.verifiableInputDidReturn(vc.verifiableInput)
        delay()
        XCTAssertTrue(delegate.didConfirm)
    }

    func test_whenRegistrationThrows_thenDelegateNotCalled() {
        delegate.didConfirm = false
        authenticationService.prepareToThrowWhenRegisteringUser()
        vc.verifiableInputDidReturn(vc.verifiableInput)
        XCTAssertFalse(delegate.didConfirm)
    }

    func test_whenRegistrationThrows_thenAlertIsShown() {
        createWindow(vc)
        authenticationService.prepareToThrowWhenRegisteringUser()
        vc.verifiableInputDidReturn(vc.verifiableInput)
        delay()
        XCTAssertNotNil(UIApplication.shared.keyWindow?.rootViewController?.presentedViewController)
        XCTAssertTrue(UIApplication.shared.keyWindow?.rootViewController?.presentedViewController is UIAlertController)
    }

}

class MockConfirmPasswordViewControllerDelegate: ConfirmPasswordViewControllerDelegate {

    var didConfirm = false
    var didTerminate = false

    func didConfirmPassword() {
        didConfirm = true
    }

}
