//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import XCTest
import CommonTestSupport

struct Rule {

    enum State {
        case inactive, success, error
    }

    var element: XCUIElement {
        return XCUIApplication().staticTexts[LocalizedString(key)]
    }
    var state: State? {
        guard let value = element.value as? String else {
            preconditionFailure("Accessibilty value is missing in Rule element")
        }
        let inactiveValue = "\(LocalizedString("rule.inactive")) \(element.label)"
        let errorValue = "\(LocalizedString("rule.error")) \(element.label)"
        let successValue = "\(LocalizedString("rule.success")) \(element.label)"
        switch value {
        case inactiveValue: return .inactive
        case errorValue: return .error
        case successValue: return .success
        default: preconditionFailure("Failed to recognize rule status")
        }
    }

    var key: String

    init(key: String) {
        self.key = key
    }
}
