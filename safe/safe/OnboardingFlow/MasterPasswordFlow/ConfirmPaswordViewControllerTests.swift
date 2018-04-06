//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class ConfirmPaswordViewControllerTests: AbstractAppTestCase {

    // swiftlint:disable weak_delegate
    let delegate = MockConfirmPasswordViewControllerDelegate()
    var vc: ConfirmPaswordViewController!

    override func setUp() {
        super.setUp()
        // TODO: pull up
        ApplicationServiceRegistry.put(service: authenticationService,
                                       for: AuthenticationApplicationService.self)

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
        vc.textInputDidReturn()
        XCTAssertTrue(authenticationService.isUserRegistered())
    }

    func test_whenRegistrationCompleted_thenCallsDelegate() {
        delegate.didConfirm = false
        vc.textInputDidReturn()
        delay()
        XCTAssertTrue(delegate.didConfirm)
    }

    func test_whenRegistrationThrows_thenDelegateNotCalled() {
        delegate.didConfirm = false
        authenticationService.prepareToThrowWhenRegisteringUser()
        vc.textInputDidReturn()
        XCTAssertFalse(delegate.didConfirm)
    }

    func test_whenRegistrationThrows_thenAlertIsShown() {
        guard let window = UIApplication.shared.keyWindow else {
            XCTFail("Must have window")
            return
        }
        window.rootViewController = vc
        window.makeKeyAndVisible()
        authenticationService.prepareToThrowWhenRegisteringUser()
        vc.textInputDidReturn()
        delay()
        XCTAssertNotNil(vc.presentedViewController)
        XCTAssertTrue(vc.presentedViewController is UIAlertController)
    }

    func test_whenTerminated_thenCallsDelegate() {
        vc.terminate()
        XCTAssertTrue(delegate.didTerminate)
    }

}

class MockConfirmPasswordViewControllerDelegate: ConfirmPasswordViewControllerDelegate {

    var didConfirm = false
    var didTerminate = false

    func didConfirmPassword() {
        didConfirm = true
    }

    func terminate() {
        didTerminate = true
    }

}
