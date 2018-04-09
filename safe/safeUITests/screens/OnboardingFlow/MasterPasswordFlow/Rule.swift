//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation
import XCTest
import CommonTestSupport

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
