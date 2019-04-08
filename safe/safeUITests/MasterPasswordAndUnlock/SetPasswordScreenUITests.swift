//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest

class SetPasswordScreenUITests: XCTestCase {

    let application = Application()
    let screen = SetPasswordScreen()
    let invalidPassword = "aaa"
    let validPassword = "abcdeF1abc"

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        application.resetAllContentAndSettings()
        application.start()
        StartScreen().start()
    }

    // MP-002
    func test_contents() {
        XCTAssertExist(screen.title)
        XCTAssertExist(screen.passwordField)
        XCTAssertTrue(screen.isKeyboardActive)
        screen.rules.all.forEach {
            XCTAssertExist($0.element)
            XCTAssertEqual($0.state, .inactive)
        }
    }

    // MP-003
    func test_whenInvalidPasswordEntered_thenRulesHaveErrors() {
        screen.enterPassword(invalidPassword)
        screen.rules.all.forEach { rule in
            XCTAssertEqual(rule.state, .error)
        }
    }

    // MP-003
    func test_whenValidPasswordEntered_thenRulesAreGreen() {
        screen.enterPassword(validPassword, hittingEnter: false)
        screen.rules.all.forEach { rule in
            XCTAssertEqual(rule.state, .success)
        }
    }

    // MP-004
    func test_whenValidPasswordEnteredAndReturnKeyHit_thenNavigatesToConfirmPassword() {
        screen.enterPassword(validPassword)
        XCTAssertTrue(ConfirmPasswordScreen().isDisplayed)
    }

}
