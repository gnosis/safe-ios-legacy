//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
import CommonTestSupport

class PendingSafeScreenUITests: UITestCase {

    let pendingScreen = PendingSafeScreen()
    let mainScreen = MainScreen()
    let newSafeScreen = NewSafeScreen()

    override func setUp() {
        super.setUp()
        application.setMockServerResponseDelay(2)
        givenDeploymentStarted()
    }

    // NS-201, NS-203, NS-209
    func test_whenStartedCreation_thenHasCorrectIntermediateValues() {
        waitUntil(pendingScreen.title, .exists)
        XCTAssertEqual(pendingScreen.progressView.value as? String, "10%")
        waitUntilAddressKnownStatus()
        XCTAssertEqual(pendingScreen.progressView.value as? String, "20%")
        waitUntilNotEnoughFundsStatus()
        XCTAssertEqual(pendingScreen.progressView.value as? String, "40%")
        XCTAssertExist(XCUIApplication().staticTexts[notEnoughFundsLabel()])
        waitUntilAccountFundedStatus()
        XCTAssertEqual(pendingScreen.progressView.value as? String, "50%")
        waitUntilDeploymentAcceptedByBlockchainStatus()
        XCTAssertEqual(pendingScreen.progressView.value as? String, "80%")
        waitUntil(mainScreen.isDisplayed, timeout: 15)
        restartTheApp()
        XCTAssertTrue(mainScreen.isDisplayed)
    }

    // NS-202
    func test_whenDismissesAbort_thenContinuesDeployment() {
        waitUntil(pendingScreen.title, .exists)
        let (alertMonitor, alertExpectation) = addAbortAlertMonitor(cancellingAlert: true)
        defer { removeUIInterruptionMonitor(alertMonitor) }
        pendingScreen.cancel.tap()
        handleAlert()
        waitUntil(mainScreen.isDisplayed, timeout: 15)
    }

    // NS-202
    func test_whenAbortsDeployment_thenGoesBack() {
        waitUntil(pendingScreen.title, .exists)
        let (monitor, expectation) = addAbortAlertMonitor(cancellingAlert: false)
        defer { removeUIInterruptionMonitor(monitor) }
        pendingScreen.cancel.tap()
        handleAlert()
        waitUntil(newSafeScreen.isDisplayed)
        restartTheApp()
        newSafeScreen.next.tap()
        waitUntil(mainScreen.isDisplayed, timeout: 15)
    }

    // NS-204
    func test_whenNotEnoughFunds_thenProgessHasCorrectValue() {
        waitUntilNotEnoughFundsStatus()
        restartTheApp(serverResponseDelay: 5)
        XCTAssertExist(XCUIApplication().staticTexts[notEnoughFundsLabel()])
    }

    // NS-205
    func test_whenCancellingDuringNotEnoughFunds_thenContinuesDeployment() {
        waitUntilNotEnoughFundsStatus()
        let (alertMonitor, alertExpectation) = addAbortAlertMonitor(cancellingAlert: true)
        defer { removeUIInterruptionMonitor(alertMonitor) }
        pendingScreen.cancel.tap()
        handleAlert()
        waitUntil(mainScreen.isDisplayed, timeout: 15)
    }

    // NS-205
    func test_whenAbortingDuringSafeCreationWithNotEnoughFunds_thenGoesBack() {
        waitUntilNotEnoughFundsStatus()
        let (monitor, expectation) = addAbortAlertMonitor(cancellingAlert: false)
        defer { removeUIInterruptionMonitor(monitor) }
        pendingScreen.cancel.tap()
        handleAlert()
        waitUntil(newSafeScreen.isDisplayed)
    }

    // NS-206, NS-207, NS-208
    func test_whenAccountIsFunded_thenCanNotAbortSafeCreation() {
        waitUntilAccountFundedStatus()
        XCTAssertFalse(pendingScreen.cancel.isEnabled)
        restartTheApp(serverResponseDelay: 5)
        XCTAssertFalse(pendingScreen.cancel.isEnabled)
        XCTAssertTrue(pendingScreen.status.label == LocalizedString("pending_safe.status.account_funded"))
        restartTheApp(serverResponseDelay: 0.1)
        waitUntil(mainScreen.isDisplayed)
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
        XCUIApplication().swipeUp() // without it, alert monitors are not firing up.
        waitForExpectations(timeout: 1)
    }

    private func notEnoughFundsLabel() -> String {
        let requiredEth = "100 Wei"
        let balanceEth = "50 Wei"
        let status = String(format: LocalizedString("pending_safe.status.not_enough_funds"), balanceEth, requiredEth)
        return status
    }

    private func waitUntilAddressKnownStatus() {
        waitUntil(pendingScreen.status.label == LocalizedString("pending_safe.status.address_known"), timeout: 10)
    }

    private func waitUntilNotEnoughFundsStatus() {
        waitUntil(pendingScreen.status.label == notEnoughFundsLabel(), timeout: 10)
    }

    private func waitUntilAccountFundedStatus() {
        waitUntil(pendingScreen.status.label == LocalizedString("pending_safe.status.account_funded"), timeout: 10)
    }

    private func waitUntilDeploymentAcceptedByBlockchainStatus() {
        waitUntil(pendingScreen.status.label == LocalizedString("pending_safe.status.deployment_accepted"), timeout: 10)
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
