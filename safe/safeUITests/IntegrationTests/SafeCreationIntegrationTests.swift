//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
import CommonTestSupport

class SafeCreationIntegrationTests: UITestCase {

    var errorAlertHandler: NSObjectProtocol!
    let cameraScreen = CameraScreen()
    let pairWithBrowserExtensionScreen = PairWithBrowserExtensionScreen()

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        if let handler = errorAlertHandler {
            removeUIInterruptionMonitor(handler)
        }
        super.tearDown()
    }

    // NS-014
//    func test_whenTryingToPairWithExpiredCode_thenShowsError() {
//        givenCameraOpened()
//        cameraScreen.scanExpiredCodeButton.tap()
//        pairWithBrowserExtensionScreen.updateButton.tap()
//        handleErrorAlert(with: expectation(description: "Error alert handled"))
//        handleAlerts()
//    }

}

private extension SafeCreationIntegrationTests {

    func handleErrorAlert(with expectation: XCTestExpectation) {
        errorAlertHandler = addUIInterruptionMonitor(withDescription: "Error Alert") { alert in
            guard alert.label == LocalizedString("onboarding.error.title") else { return false }
            alert.buttons[LocalizedString("onboarding.fatal.ok")].tap()
            expectation.fulfill()
            return true
        }
    }

    func handleAlerts() {
        delay(1)
        XCUIApplication().swipeUp() // required for alert handlers firing
        waitForExpectations(timeout: 5)
    }

}
