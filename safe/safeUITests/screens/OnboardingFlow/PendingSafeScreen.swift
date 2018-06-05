//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import XCTest

class PendingSafeScreen {

    let title = XCUIApplication().staticTexts[LocalizedString("pending_safe.title")]
    let progressView = XCUIApplication().progressIndicators.element
    let status = XCUIApplication().staticTexts["pending_safe.status"]
    let cancel = XCUIApplication().buttons[LocalizedString("pending_safe.cancel")]

}
