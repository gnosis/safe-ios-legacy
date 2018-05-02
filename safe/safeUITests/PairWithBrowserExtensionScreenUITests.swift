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

class Springboard {

    static let springboard = XCUIApplication(privateWithPath: nil, bundleID: "com.apple.springboard")

    class func deleteSafeApp() {
        guard let springboard = springboard else {
            preconditionFailure("Failed to find the app")
        }
        let terminatedStates: [XCUIApplication.State] = [.unknown, .notRunning]
        if !terminatedStates.contains(XCUIApplication().state) {
            XCUIApplication().terminate()
        }
        // Resolve the query for the springboard rather than launching it
        springboard.resolve()

        let safeIcons = springboard.icons.matching(identifier: "Safe")
        for _ in (0..<safeIcons.count) {
            let icon = safeIcons.element(boundBy: 0)
            if icon.exists {
                let iconFrame = icon.frame
                let springboardFrame = springboard.frame
                icon.press(forDuration: 1.3)

                // Tap the little "X" button at approximately where it is. The X is not exposed directly
                let xOffset = CGVector(dx: (iconFrame.minX + 3) / springboardFrame.maxX,
                                       dy: (iconFrame.minY + 3) / springboardFrame.maxY)
                springboard.coordinate(withNormalizedOffset: xOffset).tap()

                delay(1)
                springboard.buttons["Delete"].tap()
                delay(2)
                XCUIDevice.shared.press(.home)
            }
        }
    }

}
