//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import XCTest

final class TestUtils {

    private init() {}

    static func enterTextToSecureTextField(_ text: String, hittingEnter: Bool = true) {
        XCUIApplication().secureTextFields.firstMatch.typeText(text + (hittingEnter ? "\n" : ""))
    }

    static func navigateBack() {
        XCUIApplication().navigationBars.buttons["Back"].tap()
    }

}
