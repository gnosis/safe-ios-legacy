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

final class PairWithBrowserExtensionScreenSuccessUITests: PairWithBrowserExtensionScreenUITests {

    override func setUp() {
        super.setUp()
        givenBrowserExtensionSetup()
    }

    // NS-002
    func test_contents() {
        XCTAssertExist(pairWithExtensionScreen.scanButton)
        XCTAssertTrue(pairWithExtensionScreen.scanButton.isEnabled)
    }

    // NS-003
    func test_denyCameraAccess() {
        handleCameraPermissionByDenying()
        handleSuggestionAlertByCancelling(with: expectation(description: "Alerts handled"))
        pairWithExtensionScreen.scanButton.tap()
        handleAlerts()
    }

    // NS-005
    func test_allowCameraAccess() {
        givenCameraOpened()
        closeCamera()
    }

    // NS-006, NS-007
    func test_scanInvalidCode() {
        givenCameraOpened()
        cameraScreen.scanInvalidCodeButton.tap()
        XCTAssertTrue(cameraScreen.isDisplayed)
        closeCamera()
    }

    // NS-008
    func test_scanValidCode() {
        givenCameraOpened()
        cameraScreen.scanValidCodeButton.tap()
        XCTAssertTrue(newSafeScreen.browserExtension.isChecked)
    }

    // NS-010
    func test_rescanInvalidOnTopOfValid() {
        givenCameraOpened()
        cameraScreen.scanValidCodeButton.tap()
        newSafeScreen.browserExtension.element.tap()

        pairWithExtensionScreen.scanButton.tap()
        cameraScreen.scanInvalidCodeButton.tap()
        cameraScreen.closeButton.tap()
        TestUtils.navigateBack()
        XCTAssertTrue(newSafeScreen.browserExtension.isChecked)
    }

    // NS-011
    func test_rescanValidCodeOnTopOfValidCode() {
        givenCameraOpened()
        cameraScreen.scanValidCodeButton.tap()
        newSafeScreen.browserExtension.element.tap()
        pairWithExtensionScreen.scanButton.tap()
        cameraScreen.scanValidCodeButton.tap()
    }

    // NS-012
    func test_browserExtension_whenAppRestarted_thenCodeSaved() {
        givenCameraOpened()
        cameraScreen.scanValidCodeButton.tap()
        Application().terminate()
        givenNewSafeSetup(withAppReset: false)
        XCTAssertTrue(newSafeScreen.browserExtension.isChecked)
    }

}

private extension PairWithBrowserExtensionScreenUITests {

    func closeCamera() {
        XCTAssertTrue(cameraScreen.isDisplayed)
        cameraScreen.closeButton.tap()
    }

}

final class PairWithBrowserExtensionScreenErrorsUITests: PairWithBrowserExtensionScreenUITests {

    private let networkDelay: TimeInterval = 2

    // NS-ERR-001
    func test_whenNetworkErrorInPairing_thenShowsAlert() {
        application.setMockNotificationService(delay: networkDelay, shouldThrow: .networkError)
        handleNotificationServiceError()
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
        delay(networkDelay)
        handleAlerts()
    }

}
