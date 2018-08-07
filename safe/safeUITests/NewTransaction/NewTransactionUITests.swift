//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest

class NewTransactionUITests: UITestCase {

    let screen = SendTokenScreen()

    override func setUp() {
        super.setUp()
        Springboard.deleteSafeApp()
        givenSentEthScreen()
    }

    // NT-001
    func test_contents() {
        XCTAssertTrue(screen.isDisplayed)
    }

}
