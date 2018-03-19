//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation
import XCTest

final class SetPasswordScreen {

    let title = XCUIApplication().staticTexts[XCLocalizedString("onboarding.set_password.header")]

    var isDisplayed: Bool {
        return title.exists
    }

    func enterPassword(_ text: String) {
        TestUtils.enterTextToSecureTextField(text)
    }

}
