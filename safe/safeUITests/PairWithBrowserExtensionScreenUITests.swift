//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
import CommonTestSupport

class PairWithBrowserExtensionScreenUITests: UITestCase {

    let screen = PairWithBrowserExtensionScreen()
    var cameraPermissionHandler: NSObjectProtocol!
    var cameraSuggestionHandler: NSObjectProtocol!

    override func tearDown() {
        if let handler = cameraPermissionHandler {
            removeUIInterruptionMonitor(handler)
        }
        if let handler = cameraSuggestionHandler {
            removeUIInterruptionMonitor(handler)
        }
        super.tearDown()
    }

    func test_contents() {
        givenBrowserExtensionSetup()
        XCTAssertExist(screen.qrCodeInput)
        XCTAssertExist(screen.finishButton)
        XCTAssertFalse(screen.finishButton.isEnabled)
    }

    func test_requiresAppReinstalled_denyCameraAccess() {
        Springboard.deleteSafeApp()
        givenBrowserExtensionSetup()
        handleCameraPermissionByDenying()
        handleSuggestionAlertByCancelling(with: expectation(description: "Alerts handled"))
        screen.qrCodeInput.tap()
        delay(1)
        XCUIApplication().tap() // required for alert handlers firing
        waitForExpectations(timeout: 5)
    }

    func test_requiresAppReinstalled_allowCameraAccess() {
        Springboard.deleteSafeApp()
        givenBrowserExtensionSetup()
        handleCameraPermsissionByAllowing(with: expectation(description: "Alerts handled"))

        screen.qrCodeInput.tap()
        delay(1)
        XCUIApplication().tap() // required for alert handlers firing
        waitForExpectations(timeout: 5)

        closeCamera()

        XCTAssertExist(screen.qrCodeInput)
    }

}

extension PairWithBrowserExtensionScreenUITests {

    private func handleCameraPermissionByDenying() {
        cameraPermissionHandler = addUIInterruptionMonitor(withDescription: "Camera access") { alert in
            guard alert.label.localizedCaseInsensitiveContains("would like to access the camera") else { return false }
            alert.buttons["Don’t Allow"].tap()
            return true
        }
    }

    private func handleCameraPermsissionByAllowing(with expectation: XCTestExpectation) {
        cameraPermissionHandler = addUIInterruptionMonitor(withDescription: "Camera access") { alert in
            defer { expectation.fulfill() }
            guard alert.label.localizedCaseInsensitiveContains("would like to access the camera") else {
                return false
            }
            alert.buttons["OK"].tap()
            return true
        }
    }

    private func handleSuggestionAlertByCancelling(with expectation: XCTestExpectation) {
        cameraSuggestionHandler = addUIInterruptionMonitor(withDescription: "Suggestion Alert") { alert in
            guard alert.label == XCLocalizedString("scanner.camera_access_required.title", table: "safeUIKit") else {
                return false
            }
            XCTAssertExist(alert.buttons[XCLocalizedString("scanner.camera_access_required.allow", table: "safeUIKit")])
            alert.buttons[XCLocalizedString("cancel", table: "safeUIKit")].tap()
            expectation.fulfill()
            return true
        }
    }

    private func closeCamera() {
        let cameraScreen = CameraScreen()
        XCTAssertTrue(cameraScreen.isDisplayed)
        cameraScreen.closeButton.tap()
    }

}
