//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import SafeUIKit
import IdentityAccessApplication
import CommonTestSupport

class PasswordViewControllerTests: SafeTestCase {

    // swiftlint:disable:next weak_delegate
    let delegate = MockPasswordViewControllerDelegate()
    var vc: PasswordViewController!

    override func setUp() {
        super.setUp()
        prepareSetPasswordViewController()
    }

    func test_whenLoaded_thenHasAllElements() {
        XCTAssertNotNil(vc.descriptionLabel)
        XCTAssertNotNil(vc.verifiableInput)
    }

    func test_whenLoaded_thenTextInputIsSecureAndWhite() {
        XCTAssertTrue(vc.verifiableInput.isSecure)
        XCTAssertEqual(vc.verifiableInput.style, .white)
    }

    func test_whenPasswordIsSet_thenDelegateIsCalled() {
        vc.verifiableInput.text = "password"
        vc.verifiableInputDidReturn(vc.verifiableInput)
        XCTAssertEqual(delegate.password, "password")
    }

    func test_whenPasswordWasSetAndNextButtonTapped_thenDelegateIsCalled() {
        vc.verifiableInput.text = "password1"
        vc.proceed(vc as Any)
        XCTAssertEqual(delegate.password, "password1")
    }

    func test_whenPasswordIsConfirmed_thenDelegateIsCalled() {
        prepareConfirmPasswordViewController()
        vc.verifiableInputDidReturn(vc.verifiableInput)
        XCTAssertTrue(delegate.didConfirm)
    }

    func test_whenPasswordIsConfirmedAndNextTapped_thenDelegateIsCalled() {
        prepareConfirmPasswordViewController()
        vc.proceed(vc as Any)
        XCTAssertTrue(delegate.didConfirm)
    }

    func test_whenDidConfirmPassword_thenUserRegistered() {
        prepareConfirmPasswordViewController()
        XCTAssertFalse(authenticationService.isUserRegistered)
        vc.verifiableInputDidReturn(vc.verifiableInput)
        XCTAssertTrue(authenticationService.isUserRegistered)
    }

    func test_whenDidConfirmPasswordAndNextTapped_thenUserRegistered() {
        prepareConfirmPasswordViewController()
        XCTAssertFalse(authenticationService.isUserRegistered)
        vc.proceed(vc as Any)
        XCTAssertTrue(authenticationService.isUserRegistered)
    }

    func test_whenRegistrationThrows_thenDelegateIsNotCalled() {
        authenticationService.prepareToThrowWhenRegisteringUser()
        prepareConfirmPasswordViewController()
        vc.verifiableInputDidReturn(vc.verifiableInput)
        XCTAssertFalse(delegate.didConfirm)
        XCTAssertFalse(authenticationService.isUserRegistered)
    }

    func test_whenRegistrationThrows_thenAlertIsShown() {
        authenticationService.prepareToThrowWhenRegisteringUser()
        prepareConfirmPasswordViewController()
        createWindow(vc)
        vc.verifiableInputDidReturn(vc.verifiableInput)
        delay()
        XCTAssertNotNil(UIApplication.shared.keyWindow?.rootViewController?.presentedViewController)
        XCTAssertTrue(UIApplication.shared.keyWindow?.rootViewController?.presentedViewController is UIAlertController)
    }

    func test_whenSetPassword_thenTracks() {
        XCTAssertTracksAppearance(in: vc, OnboardingTrackingEvent.setPassword)
    }

    func test_whenConfirmPassword_thenTracks() {
        prepareConfirmPasswordViewController()
        XCTAssertTracksAppearance(in: vc, OnboardingTrackingEvent.confirmPassword)
    }

}

private extension PasswordViewControllerTests {

    func prepareSetPasswordViewController() {
        vc = PasswordViewController.create(delegate: delegate)
        vc.loadViewIfNeeded()
    }

    func prepareConfirmPasswordViewController() {
        vc = PasswordViewController.create(delegate: delegate, referencePassword: "password")
        vc.loadViewIfNeeded()
        vc.verifiableInput.text = "password"
    }

}

class MockPasswordViewControllerDelegate: PasswordViewControllerDelegate {

    var password: String?
    func didSetPassword(_ password: String) {
        self.password = password
    }

    var didConfirm = false
    func didConfirmPassword() {
        didConfirm = true
    }

}
