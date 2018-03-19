//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation
import XCTest

final class PasswordSuccessScreen {

    var isDisplayed: Bool {
        return XCUIApplication().staticTexts[XCLocalizedString("onboarding.passsword_success.status")].exists
    }

}
