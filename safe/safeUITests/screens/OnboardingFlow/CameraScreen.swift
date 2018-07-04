//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
import CommonTestSupport

class CameraScreen {

    var isDisplayed: Bool { return closeButton.exists }
    var closeButton: XCUIElement { return XCUIApplication().buttons[LocalizedString("camera.close")] }
    var scanValidCodeButton: XCUIElement { return XCUIApplication().buttons["Scan Valid Code"] }
    var scanInvalidCodeButton: XCUIElement { return XCUIApplication().buttons["Scan Invalid Code"] }
    var scanExpiredCodeButton: XCUIElement { return XCUIApplication().buttons["Scan Expired Code"] }
    var scanTwoValidCodes: XCUIElement { return XCUIApplication().buttons["Scan Two Valid Codes at Once"] }

}
