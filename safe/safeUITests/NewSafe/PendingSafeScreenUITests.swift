//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
import CommonTestSupport

class PendingSafeScreenUITests: UITestCase {

    let pendingScreen = PendingSafeScreen()
    let mainScreen = MainScreen()
    let newSafeScreen = NewSafeScreen()

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
        let (monitor, expectation) = addAbortAlertMonitor(cancellingAlert: false)
        defer { removeUIInterruptionMonitor(monitor) }
        pendingScreen.cancel.tap()
        handleAlert()
        waitUntil(newSafeScreen.isDisplayed)
        restartTheApp()
        newSafeScreen.next.tap()
        waitUntil(mainScreen.addressLabel, .exists)
    }

    // NS-203, NS-204
    func test_whenNotEnoughFunds_thenProgessHasCorrectValue() {
        application.setMockServerResponseDelay(2)
        givenDeploymentStarted()
        waitUntilNotEnoughFundsStatus()
        XCTAssertEqual(pendingScreen.progressView.value as? String, "40%")
        restartTheApp(serverResponseDelay: 2)
        XCTAssertExist(XCUIApplication().staticTexts[notEnoughFundsLabel()])
    }

    // NS-205
    func test_whenCancellingDuringNotEnoughFunds_thenContinuesDeployment() {
        application.setMockServerResponseDelay(2)
        givenDeploymentStarted()
        waitUntilNotEnoughFundsStatus()
        let (alertMonitor, alertExpectation) = addAbortAlertMonitor(cancellingAlert: true)
        defer { removeUIInterruptionMonitor(alertMonitor) }
        pendingScreen.cancel.tap()
        handleAlert()
        waitUntil(mainScreen.addressLabel, .exists)
    }

    // NS-205
    func test_whenAbortingDuringSafeCreation_thenGoesBack() {
        application.setMockServerResponseDelay(2)
        givenDeploymentStarted()
        waitUntilNotEnoughFundsStatus()
        let (monitor, expectation) = addAbortAlertMonitor(cancellingAlert: false)
        defer { removeUIInterruptionMonitor(monitor) }
        pendingScreen.cancel.tap()
        handleAlert()
        waitUntil(newSafeScreen.isDisplayed)
    }

}

extension PendingSafeScreenUITests {

    private func restartTheApp(serverResponseDelay: TimeInterval = 1) {
        application.terminate()
        application.resetArguments()
        application.setMockServerResponseDelay(serverResponseDelay)
        application.start()
        UnlockScreen().enterPassword(password)
    }

    private func handleAlert() {
        delay(1)
        XCUIApplication().tap()
        waitForExpectations(timeout: 1)
    }

    private func notEnoughFundsLabel() -> String {
        let requiredEth = "100 Wei"
        let balanceEth = "0 Wei"
        let status = String(format: LocalizedString("pending_safe.status.not_enough_funds"), balanceEth, requiredEth)
        return status
    }

    private func waitUntilNotEnoughFundsStatus() {
        waitUntil(pendingScreen.status.label == notEnoughFundsLabel(), timeout: 10)
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
