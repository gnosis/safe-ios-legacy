//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
import CommonTestSupport

class CameraScreen {

    var isDisplayed: Bool { return closeButton.exists }
    var closeButton: XCUIElement { return XCUIApplication().buttons[LocalizedString("camera.close")] }
    var scanValidCodeButton: XCUIElement { return XCUIApplication().buttons["Scan Valid Code"] }
    var scanAnotherValidCodeButton: XCUIElement { return XCUIApplication().buttons["Scan Another Valid Code"] }
    var scanInvalidCodeButton: XCUIElement { return XCUIApplication().buttons["Scan Invalid Code"] }
    var scanTwoValidCodes: XCUIElement { return XCUIApplication().buttons["Scan Two Valid Codes"] }

}
