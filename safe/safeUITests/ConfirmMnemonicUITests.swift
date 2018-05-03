//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
import CommonTestSupport

final class ConfirmMnemonicUITests: UITestCase {

    let confirmMnemonicScreen = ConfirmMnemonicScreen()

    override func setUp() {
        super.setUp()
        givenConfirmMnemonicSetup()
    }

    func test_contents() {
        XCTAssertTrue(confirmMnemonicScreen.isDisplayed)
        XCTAssertExist(confirmMnemonicScreen.description)
        XCTAssertExist(confirmMnemonicScreen.firstInput)
        XCTAssertExist(confirmMnemonicScreen.secondInput)
        XCTAssertTrue(confirmMnemonicScreen.firstInput.hasFocus)
        XCTAssertFalse(confirmMnemonicScreen.secondInput.hasFocus)
    }

}
