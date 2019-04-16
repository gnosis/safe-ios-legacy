//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import XCTest
import CommonTestSupport

final class ConfirmMnemonicScreen {

    var isDisplayed: Bool { return title.exists }
    var title: XCUIElement {
        return XCUIApplication().navigationBars[LocalizedString("ios_enterSeed_title")]

    }
    var firstInput: XCUIElement { return XCUIApplication().otherElements["firstInput"].textFields.firstMatch }
    var secondInput: XCUIElement { return XCUIApplication().otherElements["secondInput"].textFields.firstMatch }
    var confirmButton: XCUIElement {
        return XCUIApplication().buttons[LocalizedString("new_safe.confirm_recovery.next")]
    }
    var firstWordNumber: Int {
        return wordNumber(from: firstInput.placeholderValue ?? "")
    }
    var secondWordNumber: Int {
        return wordNumber(from: secondInput.placeholderValue ?? "")
    }
    var backButton: XCUIElement {
        return XCUIApplication().navigationBars.buttons[LocalizedString("new_safe.setup_recovery.title")]
    }

    private func wordNumber(from label: String) -> Int {
        let regexp = try! NSRegularExpression(pattern: "\\d+")
        let match = regexp.firstMatch(in: label, range: NSRange(location: 0, length: label.count))
        let result = (label as NSString).substring(with: match!.range)
        return Int(result)!
    }

}
