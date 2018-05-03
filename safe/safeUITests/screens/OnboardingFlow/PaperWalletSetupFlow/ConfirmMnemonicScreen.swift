//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import XCTest
import CommonTestSupport

final class ConfirmMnemonicScreen {

    var isDisplayed: Bool {
        return title.exists
    }

    let title = XCUIApplication().staticTexts[XCLocalizedString("recovery.confirm_mnemonic.title")]
    let description = XCUIApplication().staticTexts[XCLocalizedString("recovery.confirm_mnemonic.description")]
    let firstInput = XCUIApplication().otherElements["firstInput"].textFields.firstMatch
    let secondInput = XCUIApplication().otherElements["secondInput"].textFields.firstMatch
    let firstWordNumberLabel = XCUIApplication().staticTexts["firstWordNumberLabel"]
    let secondWordNumberLabel = XCUIApplication().staticTexts["secondWordNumberLabel"]

    func navigateBack() {
        XCUIApplication().navigationBars.buttons.firstMatch.tap()
    }

}
