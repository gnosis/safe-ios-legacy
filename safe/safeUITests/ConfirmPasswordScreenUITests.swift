//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest

class ConfirmPasswordScreenUITests: XCTestCase {

    let application = Application()
    let screen = ConfirmPasswordScreen()
    let validPassword = "abcdeF1"

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
        let sessionDurationInSeconds: TimeInterval = 3
        application.setSessionDuration(seconds: sessionDurationInSeconds)
        start()

        application.minimize()
        wait(for: sessionDurationInSeconds + 1)

        application.maximize()
        XCTAssertTrue(screen.isDisplayed)
    }

    func test_whenAppRestarted_itStartsOnStartScreen() {
        start()
        application.terminate()
        application.start()
        XCTAssertTrue(StartScreen().isDisplayed)
    }

}

extension ConfirmPasswordScreenUITests {

    private func start() {
        application.start()
        StartScreen().start()
        SetPasswordScreen().enterPassword(validPassword)
    }

}
