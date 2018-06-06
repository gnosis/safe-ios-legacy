//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import XCTest

class PendingSafeScreen {

    var isDisplayed: Bool { return title.exists }
    var title: XCUIElement { return XCUIApplication().staticTexts[LocalizedString("pending_safe.title")] }
    var progressView: XCUIElement { return XCUIApplication().progressIndicators.element }
    var status: XCUIElement { return XCUIApplication().staticTexts["pending_safe.status"] }
    var cancel: XCUIElement { return XCUIApplication().buttons[LocalizedString("pending_safe.cancel")] }

}
