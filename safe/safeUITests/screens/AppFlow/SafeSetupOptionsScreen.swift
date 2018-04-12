//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import XCTest
import CommonTestSupport

final class SetupSafeOptionsScreen {

    var isDisplayed: Bool {
        return XCUIApplication().staticTexts[XCLocalizedString("onboarding.setup_safe.info")].exists
    }

}
