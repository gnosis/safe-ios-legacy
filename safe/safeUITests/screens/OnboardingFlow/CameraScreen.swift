//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
import CommonTestSupport

class CameraScreen {

    var isDisplayed: Bool {
        return closeButton.exists
    }

    var closeButton = XCUIApplication().buttons[XCLocalizedString("camera.close", table: "safeUIKit")]
    var scanValidCodeButton = XCUIApplication().buttons["Scan Valid Code"]
    var scanAnotherValidCodeButton = XCUIApplication().buttons["Scan Another Valid Code"]
    var scanInvalidCodeButton = XCUIApplication().buttons["Scan Invalid Code"]
    var scanTwoValidCodes = XCUIApplication().buttons["Scan Two Valid Codes"]

}
