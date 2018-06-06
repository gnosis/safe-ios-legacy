//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import XCTest
import CommonTestSupport

final class ConfirmMnemonicScreen {

    var isDisplayed: Bool { return title.exists }
    var title: XCUIElement { return XCUIApplication().staticTexts[LocalizedString("recovery.confirm_mnemonic.title")] }
    var description: XCUIElement {
        return XCUIApplication().staticTexts[LocalizedString("recovery.confirm_mnemonic.description")]
    }
    var firstInput: XCUIElement { return XCUIApplication().otherElements["firstInput"].textFields.firstMatch }
    var secondInput: XCUIElement { return XCUIApplication().otherElements["secondInput"].textFields.firstMatch }
    var firstWordNumberLabel: XCUIElement { return XCUIApplication().staticTexts["firstWordNumberLabel"] }
    var secondWordNumberLabel: XCUIElement { return XCUIApplication().staticTexts["secondWordNumberLabel"] }
    var confirmButton: XCUIElement {
        return XCUIApplication().buttons[LocalizedString("recovery.confirm_mnemonic.confirm_button")]
    }
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
