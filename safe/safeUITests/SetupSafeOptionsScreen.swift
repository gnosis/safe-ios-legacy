//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import XCTest
import CommonTestSupport

class SetupSafeOptionsScreen {

    var isDisplayed: Bool { return title.exists }
    var title: XCUIElement { return XCUIApplication().staticTexts[LocalizedString("onboarding.setup_safe.info")] }
    var newSafe: XCUIElement { return XCUIApplication().buttons[LocalizedString("onboarding.setup_safe.new_safe")] }
    var restoreSafe: XCUIElement { return XCUIApplication().buttons[LocalizedString("onboarding.setup_safe.restore")] }

}
