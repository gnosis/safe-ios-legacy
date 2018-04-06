//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest

class UnlockScreenUITests: XCTestCase {

    var application = Application()
    let screen = UnlockScreen()
    let securedScreen = SetupSafeOptionsScreen()
    let validPassword = "abcdeF1"
    let invalidPassword = "a"
    var blockTime: TimeInterval = 3

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        application.resetAllContentAndSettings()
    }

    func test_whenSetPasswordFinishedAndSessionNotExpired_thenSafeSetupOptionsScreenIsDisplayed() {
        let sessionDuration: TimeInterval = 2
        application.setSessionDuration(seconds: sessionDuration)
        start()
        application.minimize()
        delay(sessionDuration - 1)
        application.maximize()
        XCTAssertTrue(securedScreen.isDisplayed)
    }

    func test_whenSetPasswordFinishedAndSessionExpired_thenUnlockIsDisplayed() {
        let sessionDuration: TimeInterval = 2
        application.setSessionDuration(seconds: sessionDuration)
        start()
        application.minimize()
        delay(sessionDuration * 2)
        application.maximize()
        guard screen.isDisplayed else {
            XCTFail("Expected to see Unlock screen")
            return
        }
        screen.enterPassword(validPassword)
        XCTAssertTrue(securedScreen.isDisplayed)
    }

    func test_whenAppRestarted_thenUnlockShown() {
        application.start()
        application.terminate()
        application.setPassword(validPassword)
        application.start()
        guard screen.isDisplayed else {
            XCTFail("Expected to see Unlock screen")
            return
        }
        screen.enterPassword(validPassword)
        XCTAssertTrue(securedScreen.isDisplayed)
    }

    func test_whenEntersWrongPasswordTooManyTimes_thenBlocksUnlocking() {
        blockTime = 5
        block(attempts: 2)
        XCTAssertExist(screen.countdown)
        delay(blockTime)
        XCTAssertNotExist(screen.countdown)
        screen.enterPassword(invalidPassword)
        XCTAssertExist(screen.countdown)
    }

    func test_whenAccountBlockedAndAppRestarted_thenUnlockingIsBlocked() {
        blockTime = 30
        block()
        application.terminate()
        delay(3)
        restart()
        delay(2)
        XCTAssertExist(screen.countdown)
    }

    func test_whenAccountBlockAndAppMaximized_thenTimerContinuesFromLastValue() {
        block()
        application.minimize()
        delay(blockTime)
        application.maximize()
        XCTAssertExist(screen.countdown)
    }

}

extension UnlockScreenUITests {

    private func block(attempts: Int = 1) {
        application.setMaxPasswordAttempts(attempts)
        application.setAccountBlockedPeriodDuration(blockTime)
        application.setPassword(validPassword)
        application.start()
        for _ in 0..<attempts {
            screen.enterPassword(invalidPassword)
        }
    }

    private func restart() {
        application = Application()
        application.setMaxPasswordAttempts(1)
        application.setAccountBlockedPeriodDuration(blockTime)
        application.start()
    }

    // move to application
    private func start() {
        application.start()
        StartScreen().start()
        SetPasswordScreen().enterPassword(validPassword)
        ConfirmPasswordScreen().enterPassword(validPassword)
    }

}
