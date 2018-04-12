//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import XCTest

class SecureTextfieldScreen {

    var title: XCUIElement {
        return XCUIApplication().staticTexts.firstMatch
    }
    let passwordField = XCUIApplication().secureTextFields.firstMatch
    var isKeyboardActive: Bool {
        return XCUIApplication().keys["space"].exists
    }
    var isDisplayed: Bool {
        return title.exists
    }

    func enterPassword(_ text: String, hittingEnter: Bool = true) {
        TestUtils.enterTextToSecureTextField(text, hittingEnter: hittingEnter)
    }

}
