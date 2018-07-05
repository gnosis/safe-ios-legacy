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
        Springboard.deleteSafeApp()
        givenBrowserExtensionSetup()
    }

    override func tearDown() {
        if let handler = errorAlertHandler {
            removeUIInterruptionMonitor(handler)
        }
        super.tearDown()
    }

    // NS-INT-102
    func test_whenTryingToPairWithExpiredCode_thenShowsError() {
        givenCameraOpened()
        cameraScreen.scanExpiredCodeButton.tap()
        handleErrorAlert(with: expectation(description: "Alert handled"))
        pairWithBrowserExtensionScreen.saveButton.tap()
        handleAlerts()
    }

}
