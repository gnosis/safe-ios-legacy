//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import XCTest
import CommonTestSupport

class PairWithBrowserExtensionScreen {

    var qrCodeInput: XCUIElement { return XCUIApplication().textFields.element }
    var qrCodeButton: XCUIElement { return XCUIApplication().buttons["QRCodeButton"] }
    var saveButton: XCUIElement { return XCUIApplication().buttons[LocalizedString("new_safe.extension.save")] }

}
