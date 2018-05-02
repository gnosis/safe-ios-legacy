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

}
