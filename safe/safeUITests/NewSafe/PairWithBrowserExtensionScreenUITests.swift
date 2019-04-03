//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
import CommonTestSupport

class PairWithBrowserExtensionScreenUITests: UITestCase {

    let pairWithExtensionScreen = PairWithBrowserExtensionScreen()
    let cameraScreen = CameraScreen()
    let newSafeScreen = NewSafeScreen()

    enum CameraOpenOption {
        case input, button
    }

    override func setUp() {
        super.setUp()
        Springboard.deleteSafeApp()
        application.setMockServerResponseDelay(0)
    }

}

// [01.04.19] DmitryBespalov: These tests are disabled because the screen changed too much
//            and this needs further revision.
final class PairWithBrowserExtensionScreenSuccessUITests: PairWithBrowserExtensionScreenUITests {

    override func setUp() {
        super.setUp()
        givenBrowserExtensionSetup()
    }
    

    // NS-002
    func invalid_test_contents() {
        XCTAssertExist(pairWithExtensionScreen.qrCodeInput)
        XCTAssertExist(pairWithExtensionScreen.scanButton)
        XCTAssertTrue(pairWithExtensionScreen.scanButton.isEnabled)
    }

    // NS-003
    func test_denyCameraAccess() {
        handleCameraPermissionByDenying()
        handleSuggestionAlertByCancelling(with: expectation(description: "Alerts handled"))
        pairWithExtensionScreen.qrCodeInput.tap()
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
        XCTAssertFalse(newSafeScreen.browserExtension.isChecked)
        newSafeScreen.browserExtension.element.tap()
        XCTAssertTrue(QRCodeInputIsEqual(to: ""))
    }

    // NS-009
    func test_scanTwoValidCodes() {
        givenCameraOpened()
        cameraScreen.scanTwoValidCodes.tap()
        XCTAssertFalse(QRCodeInputIsEqual(to: ""))
        XCTAssertTrue(pairWithExtensionScreen.saveButton.isEnabled)
        pairWithExtensionScreen.saveButton.tap()
        XCTAssertTrue(newSafeScreen.browserExtension.isChecked)
    }

    // NS-010
    func invalid_test_rescanInvalidOnTopOfValid() {
        givenCameraOpened()
        cameraScreen.scanValidCodeButton.tap()
        pairWithExtensionScreen.saveButton.tap()
        newSafeScreen.browserExtension.element.tap()

        XCTAssertFalse(pairWithExtensionScreen.updateButton.isEnabled)
        let scannedValue = pairWithExtensionScreen.qrCodeInput.value as! String
        pairWithExtensionScreen.qrCodeInput.tap()
        cameraScreen.scanInvalidCodeButton.tap()
        cameraScreen.closeButton.tap()
        XCTAssertTrue(QRCodeInputIsEqual(to: scannedValue))
        TestUtils.navigateBack()
        XCTAssertTrue(newSafeScreen.browserExtension.isChecked)
    }

    // NS-011
    func invalid_test_rescanValidCodeOnTopOfValidCode() {
        let scannedValue = rescanValidCodeOnTopOfValidWithoutUpdate()
        let newScannedValue = pairWithExtensionScreen.qrCodeInput.value as! String
        XCTAssertTrue(scannedValue != newScannedValue)
        TestUtils.navigateBack()
        newSafeScreen.browserExtension.element.tap()
        XCTAssertTrue(QRCodeInputIsEqual(to: scannedValue))
    }

    // NS-012
    func test_browserExtension_whenAppRestarted_thenCodeSaved() {
        givenCameraOpened()
        cameraScreen.scanValidCodeButton.tap()
        let scannedValue = pairWithExtensionScreen.qrCodeInput.value as! String
        pairWithExtensionScreen.saveButton.tap()
        Application().terminate()
        givenBrowserExtensionSetup(withAppReset: false)
        XCTAssertTrue(QRCodeInputIsEqual(to: scannedValue))
    }

    // NS-013
    func test_whenUpdatingValidCodeOnANewValidCode_thenNewValidCodeReplacedOld() {
        rescanValidCodeOnTopOfValidWithoutUpdate()
        let newScannedValue = pairWithExtensionScreen.qrCodeInput.value as! String
        pairWithExtensionScreen.updateButton.tap()
        newSafeScreen.browserExtension.element.tap()
        XCTAssertTrue(QRCodeInputIsEqual(to: newScannedValue))
    }

}

private extension PairWithBrowserExtensionScreenUITests {

    func closeCamera() {
        XCTAssertTrue(cameraScreen.isDisplayed)
        cameraScreen.closeButton.tap()
        XCTAssertExist(pairWithExtensionScreen.qrCodeInput)
    }

    func QRCodeInputIsEqual(to value: String) -> Bool {
        return pairWithExtensionScreen.qrCodeInput.value as? String == value
    }

    @discardableResult
    func rescanValidCodeOnTopOfValidWithoutUpdate() -> String {
        givenCameraOpened()
        cameraScreen.scanValidCodeButton.tap()
        let scannedValue = pairWithExtensionScreen.qrCodeInput.value as! String
        pairWithExtensionScreen.saveButton.tap()
        newSafeScreen.browserExtension.element.tap()
        pairWithExtensionScreen.qrCodeInput.tap()
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
        XCTAssertTrue(pairWithExtensionScreen.saveButton.isEnabled)
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
        pairWithExtensionScreen.saveButton.tap()
        XCTAssertFalse(pairWithExtensionScreen.saveButton.isEnabled)
        delay(networkDelay)
        handleAlerts()
    }


}
