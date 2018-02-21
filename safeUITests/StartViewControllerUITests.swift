//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest

class StartViewControllerUITests: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
    }

    func test_whenStarted_thenItHasStartButton() {
        XCTAssertTrue(XCUIApplication().buttons["Start"].exists)
    }

}
