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

    func test_contents() {
        XCTAssertExist(screen.title)
        XCTAssertExist(screen.description)
        XCTAssertExist(screen.startButton)
    }

    func test_start_navigatesToSetMasterPassword() {
        screen.start()
        let setPasswordScreen = SetPasswordScreen()
        XCTAssertTrue(setPasswordScreen.isDisplayed)
    }

}
