//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation
import XCTest

final class StartScreen {

    let title = XCUIApplication().staticTexts[XCLocalizedString("onboarding.start.header")]
    let description = XCUIApplication().staticTexts[XCLocalizedString("onboarding.start.description")]
    let startButton = XCUIApplication().buttons[XCLocalizedString("onboarding.start.start")]

    var isDisplayed: Bool {
        return title.exists
    }

    func start() {
        startButton.tap()
    }

}
