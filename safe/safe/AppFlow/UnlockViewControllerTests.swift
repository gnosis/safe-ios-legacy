//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class UnlockViewControllerTests: XCTestCase {

    var vc: UnlockViewController!
    let account = MockAccount()
    var didLogIn = false

    override func setUp() {
        super.setUp()
        vc = UnlockViewController.create(account: account) { [unowned self] in
            self.didLogIn = true
        }
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

    func test_whenBiometrySuccess_thenCallsCompletion() {
        authenticateWithBiometryResult(true)
        XCTAssertTrue(didLogIn)
    }

    func test_whenBiometryFails_thenNotLoggedIn() {
        authenticateWithBiometryResult(false)
        XCTAssertFalse(didLogIn)
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
        XCTAssertTrue(didLogIn)
    }

    func test_whenTextInputEntered_thenRequestsPasswordAuthentication() {
        vc.textInputDidReturn()
        XCTAssertTrue(account.didRequestPasswordAuthentication)
    }

    func test_whenPasswordPasses_thenCompletionCalled() {
        account.shouldAuthenticateWithPassword = true
        vc.textInputDidReturn()
        XCTAssertTrue(didLogIn)
    }

    func test_whenCannotAuthenticateWithBiometry_thenHidesBiometryButton() {
        account.isBiometryAuthenticationAvailable = false
        vc = UnlockViewController.create(account: account) {}
        vc.loadViewIfNeeded()
        XCTAssertTrue(vc.loginWithBiometryButton.isHidden)
    }

    func test_whenBiometryBecomesUnavailableAfterFailedAuthentication_thenHidesBiometryButton() {
        account.isBiometryAuthenticationAvailable = false
        account.shouldBiometryAuthenticationSuccess = false
        vc.loginWithBiometry(self)
        wait()
        XCTAssertTrue(vc.loginWithBiometryButton.isHidden)
    }

    func test_whenBiometryFaceID_thenUsesMatchingIcon() {
        account.isBiometryFaceID = true
        vc = UnlockViewController.create(account: account) {}
        vc.loadViewIfNeeded()
        XCTAssertEqual(vc.loginWithBiometryButton.image(for: .normal), Asset.faceIdIcon.image)
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
