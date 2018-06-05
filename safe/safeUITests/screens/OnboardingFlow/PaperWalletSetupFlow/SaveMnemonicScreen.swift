//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import XCTest
import CommonTestSupport

final class SaveMnemonicScreen {

    var isDisplayed: Bool { return title.exists }
    var title: XCUIElement { return XCUIApplication().staticTexts[LocalizedString("new_safe.paper_wallet.title")] }
    var description: XCUIElement { return XCUIApplication().staticTexts["description"] }
    var mnemonic: XCUIElement { return XCUIApplication().staticTexts["mnemonic"] }
    var saveButton: XCUIElement { return XCUIApplication().buttons[LocalizedString("new_safe.paper_wallet.save")] }
    var continueButton: XCUIElement {
        return XCUIApplication().buttons[LocalizedString("new_safe.paper_wallet.continue")]
    }

}
