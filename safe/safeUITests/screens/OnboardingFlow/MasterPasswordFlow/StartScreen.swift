//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import XCTest
import CommonTestSupport

final class StartScreen {

    var isDisplayed: Bool { return description.exists }
    var description: XCUIElement {
        return XCUIApplication().staticTexts[LocalizedString("onboarding.start.description")]
    }
    var startButton: XCUIElement {
        return XCUIApplication().buttons[LocalizedString("onboarding.start.setup_password")]
    }
    var agreeButton: XCUIElement {
        return XCUIApplication().buttons[LocalizedString("onboarding.terms.agree")]
    }

    func start() {
        startButton.tap()
        agreeButton.tap()
    }

}
