//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
import CommonTestSupport

class PairWithBrowserExtensionScreenUITests: UITestCase {

    let screen = PairWithBrowserExtensionScreen()
    var cameraPermissionHandler: NSObjectProtocol!
    var cameraSuggestionHandler: NSObjectProtocol!
    var errorAlertHandler: NSObjectProtocol!
    let cameraScreen = CameraScreen()
    let newSafe = NewSafeScreen()

    enum CameraOpenOption {
        case input, button
    }

    override func setUp() {
        super.setUp()
        Springboard.deleteSafeApp()
        application.setMockServerResponseDelay(0)
    }

    override func tearDown() {
        if let handler = cameraPermissionHandler {
            removeUIInterruptionMonitor(handler)
        }
        if let handler = cameraSuggestionHandler {
            removeUIInterruptionMonitor(handler)
        }
        super.tearDown()
    }

    func handleAlerts() {
        delay(1)
        XCUIApplication().swipeUp() // required for alert handlers firing
        waitForExpectations(timeout: 5)
    }

}

final class PairWithBrowserExtensionScreenSuccessUITests: PairWithBrowserExtensionScreenUITests {

    override func setUp() {
        super.setUp()
        givenBrowserExtensionSetup()
    }

    // NS-002
    func test_contents() {
        XCTAssertExist(screen.qrCodeInput)
        XCTAssertExist(screen.saveButton)
        XCTAssertFalse(screen.saveButton.isEnabled)
    }

    // NS-003
    func test_denyCameraAccess() {
        handleCameraPermissionByDenying()
        handleSuggestionAlertByCancelling(with: expectation(description: "Alerts handled"))
        screen.qrCodeInput.tap()
        handleAlerts()
    }

    // NS-005
    func test_allowCameraAccess() {
        givenCameraOpened()
        closeCamera()
        XCTAssertTrue(QRCodeInputIsEqual(to: ""))
    }

    // NS-006, NS-007
    func test_scanInvalidCode() {
        givenCameraOpened(with: .input)
        cameraScreen.scanInvalidCodeButton.tap()
        XCTAssertTrue(cameraScreen.isDisplayed)
        closeCamera()
        XCTAssertTrue(QRCodeInputIsEqual(to: ""))
    }

    // NS-008
    func test_scanValidCodeButDoNotFinishSetup() {
        givenCameraOpened()
        cameraScreen.scanValidCodeButton.tap()
        XCTAssertFalse(QRCodeInputIsEqual(to: ""))
        TestUtils.navigateBack()
        XCTAssertFalse(newSafe.browserExtension.isChecked)
        newSafe.browserExtension.element.tap()
        XCTAssertTrue(QRCodeInputIsEqual(to: ""))
    }

    // NS-009
    func test_scanTwoValidCodes() {
        givenCameraOpened()
        cameraScreen.scanTwoValidCodes.tap()
        XCTAssertFalse(QRCodeInputIsEqual(to: ""))
        XCTAssertTrue(screen.saveButton.isEnabled)
        screen.saveButton.tap()
        XCTAssertTrue(newSafe.browserExtension.isChecked)
    }

    // NS-010
    func test_rescanInvalidOnTopOfValid() {
        givenCameraOpened()
        cameraScreen.scanValidCodeButton.tap()
        screen.saveButton.tap()
        newSafe.browserExtension.element.tap()
        XCTAssertFalse(screen.updateButton.isEnabled)
        let scannedValue = screen.qrCodeInput.value as! String
        screen.qrCodeInput.tap()
        cameraScreen.scanInvalidCodeButton.tap()
        cameraScreen.closeButton.tap()
        XCTAssertTrue(QRCodeInputIsEqual(to: scannedValue))
        TestUtils.navigateBack()
        XCTAssertTrue(newSafe.browserExtension.isChecked)
    }

    // NS-011
    func test_rescanValidCodeOnTopOfValidCode() {
        let scannedValue = rescanValidCodeOnTopOfValidWithoutUpdate()
        let newScannedValue = screen.qrCodeInput.value as! String
        XCTAssertTrue(scannedValue != newScannedValue)
        TestUtils.navigateBack()
        newSafe.browserExtension.element.tap()
        XCTAssertTrue(QRCodeInputIsEqual(to: scannedValue))
    }

    // NS-012
    func test_browserExtension_whenAppRestarted_thenCodeSaved() {
        givenCameraOpened()
        cameraScreen.scanValidCodeButton.tap()
        let scannedValue = screen.qrCodeInput.value as! String
        screen.saveButton.tap()
        Application().terminate()
        givenBrowserExtensionSetup(withAppReset: false)
        XCTAssertTrue(QRCodeInputIsEqual(to: scannedValue))
    }

    // NS-013
    func test_whenUpdatingValidCodeOnANewValidCode_thenNewValidCodeReplacedOld() {
        rescanValidCodeOnTopOfValidWithoutUpdate()
        let newScannedValue = screen.qrCodeInput.value as! String
        screen.updateButton.tap()
        newSafe.browserExtension.element.tap()
        XCTAssertTrue(QRCodeInputIsEqual(to: newScannedValue))
    }

}

private extension PairWithBrowserExtensionScreenUITests {

    func handleCameraPermissionByDenying() {
        cameraPermissionHandler = addUIInterruptionMonitor(withDescription: "Camera access") { alert in
            guard alert.label.localizedCaseInsensitiveContains("would like to access the camera") else { return false }
            alert.buttons["Don’t Allow"].tap()
            return true
        }
    }

    func handleSuggestionAlertByCancelling(with expectation: XCTestExpectation) {
        cameraSuggestionHandler = addUIInterruptionMonitor(withDescription: "Suggestion Alert") { alert in
            guard alert.label == LocalizedString("scanner.camera_access_required.title") else {
                return false
            }
            XCTAssertExist(alert.buttons[LocalizedString("scanner.camera_access_required.allow")])
            alert.buttons[LocalizedString("cancel")].tap()
            expectation.fulfill()
            return true
        }
    }

    func closeCamera() {
        XCTAssertTrue(cameraScreen.isDisplayed)
        cameraScreen.closeButton.tap()
        XCTAssertExist(screen.qrCodeInput)
    }

    func QRCodeInputIsEqual(to value: String) -> Bool {
        return screen.qrCodeInput.value as? String == value
    }

    @discardableResult
    func rescanValidCodeOnTopOfValidWithoutUpdate() -> String {
        givenCameraOpened()
        cameraScreen.scanValidCodeButton.tap()
        let scannedValue = screen.qrCodeInput.value as! String
        screen.saveButton.tap()
        newSafe.browserExtension.element.tap()
        screen.qrCodeInput.tap()
        cameraScreen.scanValidCodeButton.tap()
        XCTAssertFalse(QRCodeInputIsEqual(to: scannedValue))
        return scannedValue
    }

}

final class PairWithBrowserExtensionScreenErrorsUITests: PairWithBrowserExtensionScreenUITests {

    private let networkDelay: TimeInterval = 2

    override func setUp() {
        super.setUp()
        application.setMockNotificationService(delay: networkDelay, shouldThrow: true)
        givenBrowserExtensionSetup()
    }

    // NS-ERR-001
    func test_whenNetworkErrorInPairing_thenShowsAlert() {
        givenCameraOpened()
        cameraScreen.scanValidCodeButton.tap()
        handleNetworkErrorAlert(with: expectation(description: "Alert handled"))
        screen.saveButton.tap()
        XCTAssertFalse(screen.saveButton.isEnabled)
        delay(networkDelay)
        handleAlerts()
        XCTAssertTrue(screen.saveButton.isEnabled)
    }

}

private extension PairWithBrowserExtensionScreenErrorsUITests {

    func handleNetworkErrorAlert(with expectation: XCTestExpectation) {
        errorAlertHandler = addUIInterruptionMonitor(withDescription: "Error Alert") { alert in
            guard alert.label == LocalizedString("onboarding.error.title") else { return false }
            alert.buttons[LocalizedString("onboarding.fatal.ok")].tap()
            expectation.fulfill()
            return true
        }
    }

}
