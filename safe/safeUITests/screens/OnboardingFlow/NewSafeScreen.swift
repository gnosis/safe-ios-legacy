//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import XCTest
import CommonTestSupport

final class NewSafeScreen {

    var isDisplayed: Bool { return title.exists }
    var title: XCUIElement { return XCUIApplication().navigationBars[LocalizedString("new_safe.title")] }
    var thisDevice: CheckButton { return CheckButton(LocalizedString("new_safe.mobile_app")) }
    var browserExtension: CheckButton { return CheckButton(LocalizedString("new_safe.browser_extension")) }
    var paperWallet: CheckButton { return CheckButton(LocalizedString("new_safe.recovery_phrase")) }
    var next: XCUIElement { return XCUIApplication().buttons[LocalizedString("new_safe.next")] }

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
