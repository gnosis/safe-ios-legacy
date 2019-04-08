//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest

class StartScreenUITests: XCTestCase {

    let application = Application()
    let screen = StartScreen()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        application.resetAllContentAndSettings()
        application.start()
    }

    // MP-001
    func test_contents() {
        XCTAssertExist(screen.description)
        XCTAssertExist(screen.startButton)
    }

    // MP-001
    func test_start_navigatesToSetMasterPassword() {
        screen.start()
        let setPasswordScreen = SetPasswordScreen()
        waitUntil(setPasswordScreen.isDisplayed)
    }

}
