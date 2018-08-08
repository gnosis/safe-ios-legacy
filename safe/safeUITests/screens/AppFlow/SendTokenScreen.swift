//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

import XCTest

class SendTokenScreen {

    var isDisplayed: Bool { return continueButton.exists }
    var continueButton: XCUIElement { return XCUIApplication().buttons[LocalizedString("transaction.continue")] }
    var amountInput: XCUIElement { return XCUIApplication().textFields["transaction.amount"] }
    var addressInput: XCUIElement { return XCUIApplication().textFields["transaction.address"] }
    var feeLabel: XCUIElement { return XCUIApplication().staticTexts["transaction.fee"] }

}
