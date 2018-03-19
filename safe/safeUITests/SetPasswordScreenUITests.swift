//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest

class SetPasswordScreenUITests: XCTestCase {

    let application = Application()
    let screen = SetPasswordScreen()

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

}
