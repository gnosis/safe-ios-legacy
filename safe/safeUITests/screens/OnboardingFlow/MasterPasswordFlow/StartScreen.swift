//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import XCTest
import CommonTestSupport

final class StartScreen {

    let title = XCUIApplication().staticTexts[LocalizedString("onboarding.start.header")]
    let description = XCUIApplication().staticTexts[LocalizedString("onboarding.start.description")]
    let startButton = XCUIApplication().buttons[LocalizedString("onboarding.start.start")]

    var isDisplayed: Bool {
        return title.exists
    }

    func start() {
        startButton.tap()
    }

}
