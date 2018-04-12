//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest

class SetPasswordScreenUITests: XCTestCase {

    let application = Application()
    let screen = SetPasswordScreen()
    let invalidPassword = "a"
    let validPassword = "abcdeF1"

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        application.resetAllContentAndSettings()
        application.start()
        StartScreen().start()
    }

    func test_contents() {
        XCTAssertExist(screen.title)
        XCTAssertExist(screen.passwordField)
        XCTAssertTrue(screen.isKeyboardActive)
        screen.rules.all.forEach {
            XCTAssertExist($0.element)
            XCTAssertEqual($0.state, .inactive)
        }
    }

    func test_whenInvalidPasswordEntered_thenRulesHaveErrors() {
        screen.enterPassword(invalidPassword)
        screen.rules.all.forEach { rule in
            XCTAssertEqual(rule.state, .error)
        }
    }

    func test_whenValidPasswordEntered_thenRulesAreGreen() {
        screen.enterPassword(validPassword, hittingEnter: false)
        screen.rules.all.forEach { rule in
            XCTAssertEqual(rule.state, .success)
        }
    }

    func test_whenValidPasswordEnteredAndReturnKeyHit_thenNavigatesToConfirmPassword() {
        screen.enterPassword(validPassword)
        XCTAssertTrue(ConfirmPasswordScreen().isDisplayed)
    }

}
