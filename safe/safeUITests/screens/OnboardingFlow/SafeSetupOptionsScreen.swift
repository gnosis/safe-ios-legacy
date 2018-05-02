//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import XCTest
import CommonTestSupport

final class NewSafeScreen {

    var isDisplayed: Bool {
        return title.exists
    }

    var title = XCUIApplication().staticTexts[XCLocalizedString("new_safe.title")]
    var thisDevice = CheckButton(XCLocalizedString("new_safe.this_device"))
    var browserExtension = CheckButton(XCLocalizedString("new_safe.browser_extension"))
    var paperWallet = CheckButton(XCLocalizedString("new_safe.paper_wallet"))

    struct CheckButton {
        let element: XCUIElement

        var enabled: Bool { return element.isEnabled }
        var isChecked: Bool {
            return hasCheckmark && element.value as? String == XCLocalizedString("button.checked", table: "safeUIKit")
        }
        var hasCheckmark: Bool { return element.value != nil }

        init(_ identifier: String) {
            element = XCUIApplication().buttons[identifier]
        }
    }
}
