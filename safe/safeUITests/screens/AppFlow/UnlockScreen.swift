//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import XCTest
import CommonTestSupport

final class UnlockScreen: SecureTextfieldScreen {

    override var isDisplayed: Bool { return XCUIApplication().otherElements["unlock.password"].exists }
    var countdown: XCUIElement { return XCUIApplication().staticTexts["countdown"] }

}
