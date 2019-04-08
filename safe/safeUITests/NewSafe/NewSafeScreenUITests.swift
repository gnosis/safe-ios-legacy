//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest

class NewSafeScreenUITests: UITestCase {

    let newSafeScreen = NewSafeScreen()

    override func setUp() {
        super.setUp()
        givenNewSafeSetup()
    
    }

    // NS-001
    func test_contents() {
        XCTAssertTrue(newSafeScreen.isDisplayed)
        XCTAssertExist(newSafeScreen.thisDevice.element)
        XCTAssertFalse(newSafeScreen.thisDevice.enabled)
        XCTAssertTrue(newSafeScreen.thisDevice.isChecked)
        XCTAssertExist(newSafeScreen.browserExtension.element)
        XCTAssertFalse(newSafeScreen.browserExtension.isChecked)
        XCTAssertExist(newSafeScreen.paperWallet.element)
        XCTAssertFalse(newSafeScreen.paperWallet.isChecked)
    }

}
