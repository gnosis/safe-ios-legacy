//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import XCTest
import CommonTestSupport

class SetupSafeOptionsScreen {

    var isDisplayed: Bool { return title.exists }
    let title = XCUIApplication().staticTexts[LocalizedString("onboarding.setup_safe.info")]
    let newSafe = XCUIApplication().buttons[LocalizedString("onboarding.setup_safe.new_safe")]
    let restoreSafe = XCUIApplication().buttons[LocalizedString("onboarding.setup_safe.restore")]

}
