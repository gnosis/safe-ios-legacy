//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation
import XCTest

final class ConfirmPasswordScreen: SecureTextfieldScreen {

    override var title: XCUIElement {
        return XCUIApplication().staticTexts[XCLocalizedString("onboarding.confirm_password.header")]
    }
    let passwordMatchRule = Rule(key: "onboarding.confirm_password.match")

}
