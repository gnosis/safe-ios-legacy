//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation
import XCTest

final class SetPasswordScreen {

    struct Rules {

        struct Rule {

            enum State {
                case inactive, success, error
            }

            var element: XCUIElement {
                return XCUIApplication().staticTexts[XCLocalizedString(key)]
            }
            var state: State? {
                guard let value = element.value as? String else {
                    return nil
                }
                switch value {
                case "rule.inactive \(element.label)": return .inactive
                case "rule.error \(element.label)": return .error
                case "rule.success \(element.label)": return .success
                default: return nil
                }
            }

            var key: String

            init(key: String) {
                self.key = key
            }
        }

        let minimumLength = Rule(key: "onboarding.set_password.length")
        let capitalLetter = Rule(key: "onboarding.set_password.capital")
        let digit = Rule(key: "onboarding.set_password.digit")

        var all: [Rule] {
            return [minimumLength, capitalLetter, digit]
        }
    }

    let title = XCUIApplication().staticTexts[XCLocalizedString("onboarding.set_password.header")]
    let passwordField = XCUIApplication().secureTextFields.firstMatch
    var isKeyboardActive: Bool {
        return XCUIApplication().keys["space"].exists
    }
    var rules = Rules()
    var isDisplayed: Bool {
        return title.exists
    }

    func enterPassword(_ text: String, hittingEnter: Bool = true) {
        TestUtils.enterTextToSecureTextField(text, hittingEnter: hittingEnter)
    }

}
