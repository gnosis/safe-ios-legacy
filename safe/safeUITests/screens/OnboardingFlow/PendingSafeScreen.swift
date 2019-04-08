//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import XCTest

class PendingSafeScreen {

    var isDisplayed: Bool { return title.exists }
    var title: XCUIElement { return XCUIApplication().navigationBars[LocalizedString("safe_creation.title")] }
    var progressView: XCUIElement { return XCUIApplication().progressIndicators.element }
    var status: XCUIElement { return XCUIApplication().staticTexts["safe_creation.status"] }
    var cancel: XCUIElement { return XCUIApplication().buttons[LocalizedString("safe_creation.cancel")] }

}
