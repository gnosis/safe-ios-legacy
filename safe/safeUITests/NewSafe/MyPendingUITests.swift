//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
import CommonTestSupport

class MyPendingSafeScreenUITests: UITestCase {

    let pendingScreen = PendingSafeScreen()
    let mainScreen = MainScreen()
    let newSafeScreen = NewSafeScreen()

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
        waitUntilNotEnoughFundsStatus()
        XCTAssertEqual(pendingScreen.progressView.value as? String, "20%")
    }

    // NS-202
    func test_whenDismissesAbort_thenContinuesDeployment() {
        application.setMockServerResponseDelay(2)
        givenDeploymentStarted()
        waitUntil(pendingScreen.title, .exists)
        let (alertMonitor, alertExpectation) = addAbortAlertMonitor(cancellingAlert: true)
        defer { removeUIInterruptionMonitor(alertMonitor) }
        pendingScreen.cancel.tap()
        handleAlert()
        waitUntil(mainScreen.addressLabel, .exists)
    }

    // NS-202
    func test_whenAbortsDeployment_thenGoesBack() {
        application.setMockServerResponseDelay(1)
        givenDeploymentStarted()
        waitUntil(pendingScreen.title, .exists)
        waitUntilNotEnoughFundsStatus()
        let (monitor, expectation) = addAbortAlertMonitor(cancellingAlert: false)
        defer { removeUIInterruptionMonitor(monitor) }
        pendingScreen.cancel.tap()
        handleAlert()
        waitUntil(newSafeScreen.isDisplayed)
    }

}

extension MyPendingSafeScreenUITests {

    private func handleAlert() {
        delay(1)
        XCUIApplication().tap()
        waitForExpectations(timeout: 1)
    }

    private func waitUntilNotEnoughFundsStatus() {
        let requiredEth = "100 Wei"
        let balanceEth = "0 Wei"
        let status = String(format: LocalizedString("pending_safe.status.not_enough_funds"), balanceEth, requiredEth)
        waitUntil(pendingScreen.status.label == status, timeout: 10)
    }

    private func addAbortAlertMonitor(cancellingAlert: Bool) -> (NSObjectProtocol, XCTestExpectation) {
        let alertExpectation = expectation(description: "abort alert")
        let alertMonitor = addUIInterruptionMonitor(withDescription: "Abort") { [unowned self] alert in
            defer { alertExpectation.fulfill() }
            guard alert.staticTexts[LocalizedString("pending_safe.abort_alert.title")].exists else { return false }
            let abortButton = alert.buttons[LocalizedString("pending_safe.abort_alert.abort")]
            XCTAssertExist(abortButton)
            let cancelButton = alert.buttons[LocalizedString("pending_safe.abort_alert.cancel")]
            XCTAssertExist(cancelButton)
            if cancellingAlert {
                cancelButton.tap()
            } else {
                abortButton.tap()
            }
            return true
        }
        return (alertMonitor, alertExpectation)
    }
}
