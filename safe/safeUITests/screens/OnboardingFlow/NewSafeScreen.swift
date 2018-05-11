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

    var title = XCUIApplication().staticTexts[LocalizedString("new_safe.title")]
    var thisDevice = CheckButton(LocalizedString("new_safe.this_device"))
    var browserExtension = CheckButton(LocalizedString("new_safe.browser_extension"))
    var paperWallet = CheckButton(LocalizedString("new_safe.paper_wallet"))
    var next = XCUIApplication().buttons[LocalizedString("new_safe.create")]

    struct CheckButton {
        let element: XCUIElement

        var enabled: Bool { return element.isEnabled }
        var isChecked: Bool {
            return hasCheckmark && element.value as? String == LocalizedString("button.checked")
        }
        var hasCheckmark: Bool { return element.value != nil }

        init(_ identifier: String) {
            element = XCUIApplication().buttons[identifier]
        }
    }

}
