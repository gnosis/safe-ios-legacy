//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import XCTest
import CommonTestSupport

class SetupSafeOptionsScreen {

    let title = XCUIApplication().staticTexts[XCLocalizedString("onboarding.setup_safe.info")]
    let newSafe = XCUIApplication().buttons[XCLocalizedString("onboarding.setup_safe.new_safe")]
    let restoreSafe = XCUIApplication().buttons[XCLocalizedString("onboarding.setup_safe.restore")]

}
