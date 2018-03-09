//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class UnlockViewControllerTests: XCTestCase {

    var vc: UnlockViewController!
    let account = MockAccount()
    // swiftlint:disable weak_delegate
    let delegate = MockUnlockViewControllerDelegate()

    override func setUp() {
        super.setUp()
        vc = UnlockViewController.create(account: account, delegate: delegate)
        vc.loadViewIfNeeded()
    }

    func test_whenCreated_hasAllElements() {
        XCTAssertNotNil(vc.textInput)
        XCTAssertNotNil(vc.loginWithBiometryButton)
        XCTAssertNotNil(vc.headerLabel)
    }

    func test_whenAppeared_thenRequestsBiometricAuthentication() {
        vc.viewDidAppear(false)
        XCTAssertTrue(account.didRequestBiometricAuthentication)
    }

    func test_whenBiometrySuccess_thenCallsDelegate() {
        authenticateWithBiometryResult(true)
        XCTAssertTrue(delegate.didLogInWasCalled)
    }

    func test_whenBiometryFails_thenNotLoggedIn() {
        authenticateWithBiometryResult(false)
        XCTAssertFalse(delegate.didLogInWasCalled)
    }

    func test_whenBiometryFails_thenFocusesOnPasswordField() {
        guard let window = UIApplication.shared.keyWindow else {
            XCTFail("Must have window")
            return
        }
        window.rootViewController = vc
        window.makeKeyAndVisible()
        authenticateWithBiometryResult(false)
        XCTAssertTrue(vc.textInput.isActive)
    }

    func test_whenBiometryButtonTapped_thenAuthenticatesWithBiometry() {
        vc.loginWithBiometry(self)
        wait()
        XCTAssertTrue(delegate.didLogInWasCalled)
    }

    func test_whenTextInputEntered_thenRequestsPasswordAuthentication() {
        vc.textInputDidReturn()
        XCTAssertTrue(account.didRequestPasswordAuthentication)
    }

    func test_whenPasswordPasses_thenDelegateCalled() {
        account.shouldAuthenticateWithPassword = true
        vc.textInputDidReturn()
        XCTAssertTrue(delegate.didLogInWasCalled)
    }

}

extension UnlockViewControllerTests {

    func authenticateWithBiometryResult(_ result: Bool) {
        account.shouldCallBiometricCompletionImmediately = false
        vc.viewDidAppear(false)
        account.completeBiometryAuthentication(success: result)
        wait()
    }

}

class MockUnlockViewControllerDelegate: UnlockViewControllerDelegate {

    var didLogInWasCalled = false

    func didLogIn() {
        didLogInWasCalled = true
    }

}
