//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import CommonTestSupport

class UnlockViewControllerTests: SafeTestCase {

    var vc: UnlockViewController!
    var didLogIn = false

    override func setUp() {
        super.setUp()
        XCTAssertNoThrow(try createVC())
    }

    func test_whenCreated_hasAllElements() {
        XCTAssertNotNil(vc.verifiableInput)
        XCTAssertNotNil(vc.loginWithBiometryButton)
        XCTAssertNotNil(vc.backgroundImageView)
        XCTAssertNotNil(vc.tryAgainLabel)
        XCTAssertNotNil(vc.countdownStack)
    }

    func test_whenCreated_thenTextInputIsSecure() {
        XCTAssertTrue(vc.verifiableInput.isSecure)
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
        createWindow(vc)
        authenticateWithBiometryResult(false)
        XCTAssertTrue(vc.verifiableInput.isActive)
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
        XCTAssertEqual(vc.loginWithBiometryButton.image(for: .normal), Asset.UnlockScreen.faceIdIcon.image)
    }

    func test_whenAccountIsBlocked_thenShowsCountdown() throws {
        authenticationService.blockAuthentication()
        try createVC()
        assertShowsCountdown()
    }

    func test_whenCountdownReachesZero_thenPasswordEntryFocused() throws {
        authenticationService.blockAuthentication()
        try createVC()
        createWindow(vc)
        clock.countdownTickBlock!(0)
        delay()
        XCTAssertTrue(vc.verifiableInput.isEnabled)
        XCTAssertTrue(vc.verifiableInput.isActive)
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
        XCTAssertTrue(vc.verifiableInput.isShaking)
    }

    func test_whenShowsCancelButtonTrue_thenHasCancelButton() {
        vc = UnlockViewController.create()
        vc.showsCancelButton = true
        vc.loadViewIfNeeded()
        XCTAssertFalse(vc.cancelButton.isHidden)
    }

}

extension UnlockViewControllerTests {

    private func hitReturn() {
        vc.verifiableInputDidReturn(vc.verifiableInput)
        delay()
    }

    private func createVC(blockPeriod: TimeInterval = 15) throws {
        try authenticationService.configureBlockDuration(blockPeriod)
        vc = UnlockViewController.create { [unowned self] success in
            self.didLogIn = success
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
        XCTAssertFalse(vc.verifiableInput.isEnabled, line: line)
    }

}
