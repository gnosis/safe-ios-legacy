//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
import CommonTestSupport

class MyPendingSafeScreenUITests: UITestCase {

    let pendingScreen = PendingSafeScreen()
    let mainScreen = MainScreen()

    class PendingSafeScreen {
        let title = XCUIApplication().staticTexts[LocalizedString("pending_safe.title")]
        let progressView = XCUIApplication().progressIndicators.element
        let status = XCUIApplication().staticTexts["pending_safe.status"]
        let cancel = XCUIApplication().buttons[LocalizedString("pending_safe.cancel")]
    }

    // NS-201
    func test_whenStartedCreation_thenStartsAtSmallProgress() {
        application.setMockServerResponseDelay(100)
        givenDeploymentStarted()
        waitUntil(pendingScreen.title, .exists)
        XCTAssertEqual(pendingScreen.progressView.value as? String, "10%")
    }

    // NS-201
    func test_whenGotNewAddress_thenDisplaysIt() {
        application.setMockServerResponseDelay(1)
        givenDeploymentStarted()
        waitUntil(pendingScreen.title, .exists)
        let requiredEth = "100 Wei"
        let balanceEth = "0 Wei"
        let status = String(format: LocalizedString("pending_safe.status.not_enough_funds"), balanceEth, requiredEth)
        waitUntil(pendingScreen.status.label == status, timeout: 10)
        XCTAssertEqual(pendingScreen.progressView.value as? String, "20%")
    }

    // NS-202
    func test_whenDismissesAbort_thenContinuesDeployment() {
        application.setMockServerResponseDelay(2)
        givenDeploymentStarted()
        waitUntil(pendingScreen.title, .exists)
        let alertExpectation = expectation(description: "abort alert")
        let alertSubscription = addUIInterruptionMonitor(withDescription: "Abort") { [unowned self] alert in
            defer { alertExpectation.fulfill() }
            guard alert.title == LocalizedString("pending_safe.abort_alert.title") else { return false }
            XCTAssertEqual(alert.title, LocalizedString("pending_safe.abort_alert.message"))
            XCTAssertExist(alert.buttons[LocalizedString("pending_safe.abort_alert.abort")])
            let cancelButton = alert.buttons[LocalizedString("pending_safe.abort_alert.cancel")]
            XCTAssertExist(cancelButton)
            cancelButton.tap()
            return true
        }
        defer { removeUIInterruptionMonitor(alertSubscription) }
        pendingScreen.cancel.tap()
        delay(1)
        XCUIApplication().tap()
        waitForExpectations(timeout: 1)
        waitUntil(mainScreen.addressLabel, .exists)
    }

}
