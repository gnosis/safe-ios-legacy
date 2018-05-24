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
        XCTAssertNotNil(vc.textInput)
    }

    func test_whenCreated_thenTextInputIsSecure() {
        XCTAssertTrue(vc.textInput.isSecure)
    }

    func test_whenDidConfirmPassword_thenUserRegistered() {
        XCTAssertNotNil(ApplicationServiceRegistry.authenticationService)
        vc.textInputDidReturn(vc.textInput)
        XCTAssertTrue(authenticationService.isUserRegistered)
    }

    func test_whenRegistrationCompleted_thenCallsDelegate() {
        delegate.didConfirm = false
        vc.textInputDidReturn(vc.textInput)
        delay()
        XCTAssertTrue(delegate.didConfirm)
    }

    func test_whenRegistrationThrows_thenDelegateNotCalled() {
        delegate.didConfirm = false
        authenticationService.prepareToThrowWhenRegisteringUser()
        vc.textInputDidReturn(vc.textInput)
        XCTAssertFalse(delegate.didConfirm)
    }

    func test_whenRegistrationThrows_thenAlertIsShown() {
        createWindow(vc)
        authenticationService.prepareToThrowWhenRegisteringUser()
        vc.textInputDidReturn(vc.textInput)
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
