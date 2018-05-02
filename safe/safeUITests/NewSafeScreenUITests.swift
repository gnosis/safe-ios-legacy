//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest

class NewSafeScreenUITests: UITestCase {

    let screen = NewSafeScreen()

    override func setUp() {
        super.setUp()
        givenNewSafeSetup()
    }

    func test_contents() {
        XCTAssertTrue(screen.isDisplayed)
        XCTAssertExist(screen.thisDevice.element)
        XCTAssertFalse(screen.thisDevice.enabled)
        XCTAssertTrue(screen.thisDevice.isChecked)
        XCTAssertExist(screen.browserExtension.element)
        XCTAssertFalse(screen.browserExtension.isChecked)
        XCTAssertExist(screen.paperWallet.element)
        XCTAssertFalse(screen.paperWallet.isChecked)
    }

}
