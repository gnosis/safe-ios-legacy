//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import XCTest
import CommonTestSupport

final class SetPasswordScreen: SecureTextfieldScreen {

    struct Rules {

        let minimumLength = Rule(key: "onboarding.set_password.length")
        let noTrippleChars = Rule(key: "onboarding.set_password.no_tripple_chars")
        let letterAndDigit = Rule(key: "onboarding.set_password.letter_and_digit")

        var all: [Rule] {
            return [minimumLength, noTrippleChars, letterAndDigit]
        }

    }

    override var title: XCUIElement {
        return XCUIApplication().navigationBars[LocalizedString("onboarding.set_password.title")]
    }

    var rules = Rules()

}
