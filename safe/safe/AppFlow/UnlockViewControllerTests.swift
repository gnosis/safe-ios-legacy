//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe
import CommonTestSupport

class UnlockViewControllerTests: SafeTestCase {

    var vc: UnlockViewController!
    var didLogIn = false

    override func setUp() {
        super.setUp()
        createVC()
    }

    func test_whenCreated_hasAllElements() {
        XCTAssertNotNil(vc.textInput)
        XCTAssertNotNil(vc.loginWithBiometryButton)
        XCTAssertNotNil(vc.headerLabel)
    }

    func test_whenCreated_thenTextInputIsSecure() {
        XCTAssertTrue(vc.textInput.isSecure)
    }

    func test_whenAppeared_thenRequestsBiometricAuthentication() {
        vc.viewDidAppear(false)
        XCTAssertTrue(authenticationService.didRequestBiometricAuthentication)
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
        authenticationService.allowAuthentication()
        vc.loginWithBiometry(self)
        delay()
        XCTAssertTrue(didLogIn)
    }

    func test_whenTextInputEntered_thenRequestsPasswordAuthentication() {
        delay()
        hitReturn()
        XCTAssertTrue(authenticationService.didRequestPasswordAuthentication)
    }

    func test_whenPasswordPasses_thenCompletionCalled() {
        authenticationService.allowAuthentication()
        hitReturn()
        XCTAssertTrue(didLogIn)
    }

    func test_whenCannotAuthenticateWithBiometry_thenHidesBiometryButton() {
        authenticationService.makeBiometricAuthenticationImpossible()
        vc = UnlockViewController.create()
        vc.loadViewIfNeeded()
        XCTAssertTrue(vc.loginWithBiometryButton.isHidden)
    }

    func test_whenBiometryBecomesUnavailableAfterFailedAuthentication_thenHidesBiometryButton() {
        authenticationService.makeBiometricAuthenticationImpossible()
        authenticationService.invalidateAuthentication()
        vc.loginWithBiometry(self)
        delay()
        XCTAssertTrue(vc.loginWithBiometryButton.isHidden)
    }

    func test_whenBiometryFaceID_thenUsesMatchingIcon() {
        authenticationService.enableFaceIDSupport()
        vc = UnlockViewController.create()
        vc.loadViewIfNeeded()
        XCTAssertEqual(vc.loginWithBiometryButton.image(for: .normal), Asset.faceIdIcon.image)
    }

    func test_whenAccountIsBlocked_thenShowsCountdown() {
        authenticationService.blockAuthentication()
        createVC()
        assertShowsCountdown()
    }

    func test_whenCountdownReachesZero_thenPasswordEntryFocused() {
        authenticationService.blockAuthentication()
        createVC()
        guard let window = UIApplication.shared.keyWindow else {
            XCTFail("Must have window")
            return
        }
        window.rootViewController = vc
        clock.countdownTickBlock!(0)
        delay()
        XCTAssertTrue(vc.textInput.isEnabled)
        XCTAssertTrue(vc.textInput.isActive)
    }

    func test_whenWasBlockedBeforeEnteringPassword_thenBlocksPasswordEntry() {
        authenticationService.blockAuthentication()
        hitReturn()
        assertShowsCountdown()
    }

    func test_whenAccountBlocked_thenMustNotRequestBiometricAuthentication() {
        authenticationService.blockAuthentication()
        vc.viewDidAppear(false)
        XCTAssertFalse(authenticationService.didRequestBiometricAuthentication)
    }

    func test_whenPasswordFails_thenInputShakes() {
        authenticationService.invalidateAuthentication()
        hitReturn()
        XCTAssertTrue(vc.textInput.isShaking)
    }

}

extension UnlockViewControllerTests {

    private func hitReturn() {
        vc.textInputDidReturn()
        delay()
    }

    private func createVC(blockPeriod: TimeInterval = 15) {
        authenticationService.configureBlockDuration(blockPeriod)
        vc = UnlockViewController.create { [unowned self] in
            self.didLogIn = true
        }
        UIApplication.shared.keyWindow?.rootViewController = vc
    }

    private func authenticateWithBiometryResult(_ result: Bool) {
        if result {
            authenticationService.allowAuthentication()
        } else {
            authenticationService.invalidateAuthentication()
        }
        vc.viewDidAppear(false)
        delay()
    }

    private func assertShowsCountdown(line: UInt = #line) {
        XCTAssertNotNil(vc.countdownLabel, line: line)
        XCTAssertTrue(vc.loginWithBiometryButton.isHidden, line: line)
        XCTAssertFalse(vc.textInput.isEnabled, line: line)
    }

}
