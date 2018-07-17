//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
import CommonTestSupport

class PairWithBrowserExtensionScreenUITests: UITestCase {

    let screen = PairWithBrowserExtensionScreen()
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

    // NS-ERR-001
    func test_whenNetworkErrorInPairing_thenShowsAlert() {
        application.setMockNotificationService(delay: networkDelay, shouldThrow: .networkError)
        handleNotificationServiceError()
        XCTAssertTrue(screen.saveButton.isEnabled)
    }

    // NS-ERR-002
    func test_whenResponseValidationErrorInPairing_thenShowsAlert() {
        application.setMockNotificationService(delay: networkDelay, shouldThrow: .validationError)
        handleNotificationServiceError()
    }

    private func handleNotificationServiceError() {
        givenBrowserExtensionSetup()
        givenCameraOpened()
        cameraScreen.scanValidCodeButton.tap()
        handleErrorAlert(with: expectation(description: "Alert handled"))
        screen.saveButton.tap()
        XCTAssertFalse(screen.saveButton.isEnabled)
        delay(networkDelay)
        handleAlerts()
    }


}
