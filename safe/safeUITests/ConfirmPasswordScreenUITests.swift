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
        application.start()
        StartScreen().start()
        SetPasswordScreen().enterPassword(validPassword)
    }

    func test_contents() {
        XCTAssertExist(screen.title)
        XCTAssertExist(screen.passwordField)
        XCTAssertTrue(screen.isKeyboardActive)
        XCTAssertExist(screen.passwordMatchRule.element)
        XCTAssertEqual(screen.passwordMatchRule.state, .inactive)
    }

}
