//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation
import XCTest

final class StartScreen {

    func start() {
        XCUIApplication().buttons[XCLocalizedString("onboarding.start.start")].tap()
    }

}
