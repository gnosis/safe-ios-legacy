//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
import CommonTestSupport

class UnlockScreenUITests: UITestCase {

    let screen = UnlockScreen()
    let securedScreen = SetupSafeOptionsScreen()
    let invalidPassword = "a"
    var blockTime: TimeInterval = 3

    override func setUp() {
        super.setUp()
        application.resetAllContentAndSettings()
    }

    // MP-101
    func test_whenSetPasswordFinishedAndSessionNotExpired_thenSafeSetupOptionsScreenIsDisplayed() {
        let sessionDuration: TimeInterval = 10
        application.setSessionDuration(seconds: sessionDuration)
        givenMasterPasswordIsSet()
        application.minimize()
        delay(1)
        application.maximize()
        XCTAssertTrue(securedScreen.isDisplayed)
    }

    // MP-102
    func test_whenSetPasswordFinishedAndSessionExpired_thenUnlockIsDisplayed() {
        let sessionDuration: TimeInterval = 2
        application.setSessionDuration(seconds: sessionDuration)
        givenMasterPasswordIsSet()
        application.minimize()
        delay(sessionDuration * 2)
        application.maximize()
        guard screen.isDisplayed else {
            XCTFail("Expected to see Unlock screen")
            return
        }
        screen.enterPassword(password)
        XCTAssertTrue(securedScreen.isDisplayed)
    }

    // MP-103
    func test_whenAppRestarted_thenUnlockShown() {
        givenUnlockedAppSetup()
        XCTAssertTrue(securedScreen.isDisplayed)
    }

    // MP-104
    func test_whenEntersWrongPasswordTooManyTimes_thenBlocksUnlocking() {
        blockTime = 5
        block(attempts: 2)
        XCTAssertExist(screen.countdown)
        delay(blockTime)
        XCTAssertNotExist(screen.countdown)
        screen.enterPassword(invalidPassword)
        XCTAssertExist(screen.countdown)
    }

    // MP-105
    func test_whenAccountBlockAndAppMaximized_thenTimerContinuesFromLastValue() {
        block()
        application.minimize()
        delay(blockTime)
        application.maximize()
        XCTAssertExist(screen.countdown)
    }

    // WA-461
    func test_whenEmptyPassword_thenIsNotAuthenticated() {
        application.setPassword(password)
        application.setSessionDuration(seconds: 10)
        restart()
        screen.enterPassword("")
        delay()
        XCTAssertNotExist(XCUIApplication().staticTexts["Fatal error"])
    }

}

extension UnlockScreenUITests {

    private func block(attempts: Int = 1) {
        application.setMaxPasswordAttempts(attempts)
        application.setAccountBlockedPeriodDuration(blockTime)
        application.setPassword(password)
        application.start()
        for _ in 0..<attempts {
            screen.enterPassword(invalidPassword)
        }
    }

    private func restart() {
        application.setMaxPasswordAttempts(1)
        application.setAccountBlockedPeriodDuration(blockTime)
        application.start()
    }

}
