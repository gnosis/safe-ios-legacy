//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
import CommonTestSupport

class PairWithBrowserExtensionScreenUITests: UITestCase {

    let screen = PairWithBrowserExtensionScreen()

    override func setUp() {
        super.setUp()
        givenBrowserExtensionSetup()
    }

    func test_contents() {
        XCTAssertExist(screen.qrCodeInput)
        XCTAssertExist(screen.finishButton)
        XCTAssertFalse(screen.finishButton.isEnabled)
    }

    func test_requiresAppReinstalled_denyCameraAccess() {
        let expectation = self.expectation(description: "Alerts handled")
        let handler1 = addUIInterruptionMonitor(withDescription: "Camera access") { alert in
            guard alert.label.localizedCaseInsensitiveContains("would like to access the camera") else { return false }
            alert.buttons["Don’t Allow"].tap()
            return true
        }
        let handler2 = addUIInterruptionMonitor(withDescription: "Suggestion Alert") { alert in
            guard alert.label == XCLocalizedString("scanner.camera_access_required.title", table: "safeUIKit") else {
                return false
            }
            alert.buttons[XCLocalizedString("cancel", table: "safeUIKit")].tap()
            expectation.fulfill()
            return true
        }
        screen.qrCodeInput.tap()
        delay(1)
        XCUIApplication().tap() // required for alert handlers firing
        waitForExpectations(timeout: 5)
        removeUIInterruptionMonitor(handler1)
        removeUIInterruptionMonitor(handler2)
        Springboard.deleteSafeApp()
    }

}
