//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
import CommonTestSupport

class UnlockScreenUITests: UITestCase {

    let unlockScreen = UnlockScreen()
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
        delay(0.5) // screen transition animation
        application.minimize()
        delay(sessionDuration * 2)
        application.maximize()
        delay(0.5) // open animation
        guard unlockScreen.isDisplayed else {
            XCTFail("Expected to see Unlock screen")
            return
        }
        unlockScreen.enterPassword(password)
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
        XCTAssertExist(unlockScreen.countdown)
        delay(blockTime)
        XCTAssertNotExist(unlockScreen.countdown)
        unlockScreen.enterPassword(invalidPassword)
        XCTAssertExist(unlockScreen.countdown)
    }

    // MP-105
    func test_whenAccountBlockAndAppMaximized_thenTimerContinuesFromLastValue() {
        blockTime = 5
        block()
        application.minimize()
        delay(1)
        application.maximize()
        XCTAssertExist(unlockScreen.countdown)
    }

    // MP-003
    func test_whenEmptyPassword_thenIsNotAuthenticated() {
        application.setPassword(password)
        application.setSessionDuration(seconds: 10)
        restart()
        unlockScreen.enterPassword("")
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
            unlockScreen.enterPassword(invalidPassword)
        }
    }

    private func restart() {
        application.setMaxPasswordAttempts(1)
        application.setAccountBlockedPeriodDuration(blockTime)
        application.start()
    }

}
