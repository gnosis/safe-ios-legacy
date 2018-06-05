//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import XCTest
import CommonTestSupport

final class SetPasswordScreen: SecureTextfieldScreen {

    struct Rules {

        let minimumLength = Rule(key: "onboarding.set_password.length")
        let capitalLetter = Rule(key: "onboarding.set_password.capital")
        let digit = Rule(key: "onboarding.set_password.digit")

        var all: [Rule] {
            return [minimumLength, capitalLetter, digit]
        }

    }

    override var title: XCUIElement {
        return XCUIApplication().staticTexts[LocalizedString("onboarding.set_password.header")]
    }
    
    var rules = Rules()

}
