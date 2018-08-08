//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
import CommonTestSupport

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
        XCTAssertExist(screen.amountInput)
        XCTAssertExist(screen.addressInput)
        XCTAssertExist(screen.feeLabel)
    }

    // NT-002
    func test_whenTryingToSendMoreThanBalance_thenErrorIsDisplayed() {
        screen.amountInput.tap()
        screen.amountInput.typeText("0.99")
        XCTAssertNotExist(screen.notEnoughFundsError)
        screen.amountInput.buttons["Clear text"].tap()
        screen.amountInput.typeText("1.001")
        XCTAssertExist(screen.notEnoughFundsError)
    }

    // NT-003
    func test_whenTypingReceiverAddress_thenShowsErrorForIncompleteAddress() {
        screen.addressInput.tap()
        screen.addressInput.typeText("0x728cafe9fb8cc2218fb12a9a2d9335193caa07")
        XCTAssertExist(screen.addressLengthError)
        screen.addressInput.typeText("e0")
        XCTAssertNotExist(screen.addressLengthError)
    }

}
