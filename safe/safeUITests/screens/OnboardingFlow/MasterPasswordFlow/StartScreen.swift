//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import XCTest
import CommonTestSupport

final class StartScreen {

    var isDisplayed: Bool { return title.exists }
    var title: XCUIElement { return XCUIApplication().staticTexts[LocalizedString("onboarding.start.header")] }
    var description: XCUIElement {
        return XCUIApplication().staticTexts[LocalizedString("onboarding.start.description")]
    }
    var startButton: XCUIElement { return XCUIApplication().buttons[LocalizedString("onboarding.start.start")] }

    func start() {
        startButton.tap()
    }

}
