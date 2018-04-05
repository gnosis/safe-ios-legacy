//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class UnlockViewControllerTests: XCTestCase {

    var vc: UnlockViewController!
    let account = MockAccount()
    let clock = MockClockService()
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
        delay()
        XCTAssertTrue(didLogIn)
    }

    func test_whenTextInputEntered_thenRequestsPasswordAuthentication() {
        hitReturn()
        XCTAssertTrue(account.didRequestPasswordAuthentication)
    }

    func test_whenPasswordPasses_thenCompletionCalled() {
        account.shouldAuthenticateWithPassword = true
        hitReturn()
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
        delay()
        XCTAssertTrue(vc.loginWithBiometryButton.isHidden)
    }

    func test_whenBiometryFaceID_thenUsesMatchingIcon() {
        account.isBiometryFaceID = true
        vc = UnlockViewController.create(account: account) {}
        vc.loadViewIfNeeded()
        XCTAssertEqual(vc.loginWithBiometryButton.image(for: .normal), Asset.faceIdIcon.image)
    }

    func test_whenAccountIsBlocked_thenShowsCountdown() {
        account.isBlocked = true
        createVC()
        assertShowsCountdown()
    }

    func test_whenCountdownReachesZero_thenPasswordEntryFocused() {
        account.isBlocked = true
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

    fileprivate func hitReturn() {
        vc.textInputDidReturn()
        delay()
    }

    func test_whenAfterEnteringPasswordAccountIsBlocked_thenBlocksPasswordEntry() {
        account.shouldAuthenticateWithPassword = false
        account.isBlocked = true
        hitReturn()
        assertShowsCountdown()
    }

    func test_whenAccountBlocked_thenMustNotRequestBiometricAuthentication() {
        account.isBlocked = true
        vc.viewDidAppear(false)
        XCTAssertFalse(account.didRequestBiometricAuthentication)
    }

    func test_whenPasswordFails_thenInputShakes() {
        account.shouldAuthenticateWithPassword = false
        hitReturn()
        XCTAssertTrue(vc.textInput.isShaking)
    }

}

extension UnlockViewControllerTests {

    private func createVC(blockPeriod: TimeInterval = 15) {
        account.blockedPeriodDuration = blockPeriod
        vc = UnlockViewController.create(account: account,
                                         clockService: clock) { [unowned self] in
                                            self.didLogIn = true
        }
        UIApplication.shared.keyWindow?.rootViewController = vc
    }

    private func authenticateWithBiometryResult(_ result: Bool) {
        account.shouldCallBiometricCompletionImmediately = false
        vc.viewDidAppear(false)
        account.completeBiometryAuthentication(success: result)
        delay()
    }

    private func assertShowsCountdown(line: UInt = #line) {
        XCTAssertNotNil(vc.countdownLabel, line: line)
        XCTAssertTrue(vc.loginWithBiometryButton.isHidden, line: line)
        XCTAssertFalse(vc.textInput.isEnabled, line: line)
    }

}
