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

    let title = XCUIApplication().staticTexts[LocalizedString("recovery.confirm_mnemonic.title")]
    let description = XCUIApplication().staticTexts[LocalizedString("recovery.confirm_mnemonic.description")]
    let firstInput = XCUIApplication().otherElements["firstInput"].textFields.firstMatch
    let secondInput = XCUIApplication().otherElements["secondInput"].textFields.firstMatch
    let firstWordNumberLabel = XCUIApplication().staticTexts["firstWordNumberLabel"]
    let secondWordNumberLabel = XCUIApplication().staticTexts["secondWordNumberLabel"]
    let confirmButton = XCUIApplication().buttons[LocalizedString("recovery.confirm_mnemonic.confirm_button")]

    var firstWordNumber: Int {
        return wordNumber(from: firstWordNumberLabel.label)
    }

    var secondWordNumber: Int {
        return wordNumber(from: secondWordNumberLabel.label)
    }

    private func wordNumber(from label: String) -> Int {
        let regexp = try! NSRegularExpression(pattern: "\\d+")
        let match = regexp.firstMatch(in: label, range: NSRange(location: 0, length: label.count))
        let result = (label as NSString).substring(with: match!.range)
        return Int(result)!
    }

}
