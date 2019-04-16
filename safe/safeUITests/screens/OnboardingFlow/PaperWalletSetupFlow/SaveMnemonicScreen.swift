//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import XCTest
import CommonTestSupport

final class SaveMnemonicScreen {

    var isDisplayed: Bool { return title.exists }
    var title: XCUIElement { return XCUIApplication().navigationBars[LocalizedString("new_safe.setup_recovery.title")] }
    var description: XCUIElement { return XCUIApplication().staticTexts["description"] }
    var mnemonic: XCUIElement { return XCUIApplication().staticTexts["mnemonic"] }
    var copyButton: XCUIElement { return XCUIApplication().buttons[LocalizedString("ios_showSeed_copy")] }
    var continueButton: XCUIElement {
        return XCUIApplication().buttons[LocalizedString("new_safe.setup_recovery.next")]
    }
    var backButton: XCUIElement {
        // UI testing system shows not the visible "Back" button but the button with the title of the previous screen.
        return XCUIApplication().buttons[LocalizedString("onboarding.guidelines.title")]
    }

}
