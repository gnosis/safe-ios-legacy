//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
import CommonTestSupport

class ConfirmPasswordScreenUITests: XCTestCase {

    let application = Application()
    let screen = ConfirmPasswordScreen()
    let validPassword = "abcdeF1"
    let invalidPassword = "a"

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        application.resetAllContentAndSettings()
    }

    func test_contents() {
        start()
        XCTAssertExist(screen.title)
        XCTAssertExist(screen.passwordField)
        XCTAssertTrue(screen.isKeyboardActive)
        XCTAssertExist(screen.passwordMatchRule.element)
        XCTAssertEqual(screen.passwordMatchRule.state, .inactive)
    }

    func test_whenSessionInvalidatedAndAppRestoredToForeground_confirmScreenIsDisplayed() {
        let sessionDurationInSeconds: TimeInterval = 1
        application.setSessionDuration(seconds: sessionDurationInSeconds)
        start()

        application.minimize()
        delay(sessionDurationInSeconds + 1)

        application.maximize()
        XCTAssertTrue(screen.isDisplayed)
    }

    func test_whenAppRestarted_itStartsOnStartScreen() {
        start()
        application.terminate()
        application.start()
        XCTAssertTrue(StartScreen().isDisplayed)
    }

    func test_whenEnteredDifferentPassword_thenRuleError() {
        start()
        screen.enterPassword(invalidPassword)
        XCTAssertEqual(screen.passwordMatchRule.state, .error)
    }

    func test_whenEnteredMatchingPassword_thenRuleSuccess() {
        start()
        screen.enterPassword(validPassword, hittingEnter: false)
        XCTAssertEqual(screen.passwordMatchRule.state, .success)
    }

    func test_whenEnteredMatchingPasswordAndHitEnter_thenSafeSetupOptionsScreenDisplayed() {
        start()
        screen.enterPassword(validPassword)
        XCTAssertTrue(NewSafeScreen().isDisplayed)
    }

}

extension ConfirmPasswordScreenUITests {

    private func start() {
        application.start()
        StartScreen().start()
        SetPasswordScreen().enterPassword(validPassword)
    }

}
