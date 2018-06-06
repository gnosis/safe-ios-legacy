//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import XCTest
import CommonTestSupport

final class UnlockScreen: SecureTextfieldScreen {

    override var title: XCUIElement { return XCUIApplication().staticTexts[LocalizedString("app.unlock.header")] }
    var countdown: XCUIElement { return XCUIApplication().staticTexts["countdown"] }

}
