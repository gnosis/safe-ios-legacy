//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
import CommonTestSupport

class UITestCase: XCTestCase {

    let application = Application()
    let password = "11111A"
    private var cameraSuggestionHandler: NSObjectProtocol!
    private var cameraPermissionHandler: NSObjectProtocol!
    private var errorAlertHandler: NSObjectProtocol!
    private var cameraPermissionExpectation: XCTestExpectation!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    override func tearDown() {
        if let handler = cameraPermissionHandler {
            removeUIInterruptionMonitor(handler)
        }
        if let handler = cameraSuggestionHandler {
            removeUIInterruptionMonitor(handler)
        }
        if let handler = errorAlertHandler {
            removeUIInterruptionMonitor(handler)
        }
        super.tearDown()
    }

    func givenMasterPasswordIsSet() {
        application.start()
        StartScreen().start()
        SetPasswordScreen().enterPassword(password)
        ConfirmPasswordScreen().enterPassword(password)
    }

    func givenUnlockedAppSetup(withAppReset: Bool = true) {
        if withAppReset {
            application.resetAllContentAndSettings()
            application.setPassword(password)
        } else {
            application.resetArguments()
        }
        application.start()
        UnlockScreen().enterPassword(password)
    }

    func givenNewSafeSetup(withAppReset: Bool = true) {
        givenUnlockedAppSetup(withAppReset: withAppReset)
        let setupOptions = SetupSafeOptionsScreen()
        if withAppReset {
            setupOptions.newSafe.tap()
        }
    }

    func givenBrowserExtensionSetup(withAppReset: Bool = true) {
        givenNewSafeSetup(withAppReset: withAppReset)
        NewSafeScreen().browserExtension.element.tap()
    }

    func givenSaveMnemonicSetup() {
        givenNewSafeSetup()
        NewSafeScreen().paperWallet.element.tap()
    }

    func givenConfirmMnemonicSetup() {
        givenSaveMnemonicSetup()
        SaveMnemonicScreen().continueButton.tap()
    }

    func givenDeploymentStarted() {
        let newSafeScreen = NewSafeScreen()
        let pairWithBrowserScreen = PairWithBrowserExtensionScreen()
        let cameraScreen = CameraScreen()

        givenNewSafeSetup()
        newSafeScreen.paperWallet.element.tap()
        confirmPaperWalletWithValidWords()
        newSafeScreen.browserExtension.element.tap()
        givenCameraOpened()
        cameraScreen.scanValidCodeButton.tap()
        pairWithBrowserScreen.saveButton.tap()        
        newSafeScreen.next.tap()
    }

    @discardableResult
    func confirmPaperWalletWithValidWords(withConfirmButton: Bool = false) -> String {
        let saveMnemonicScreen = SaveMnemonicScreen()
        let confirmMnemonicScreen = ConfirmMnemonicScreen()

        let mnemonic = saveMnemonicScreen.mnemonic.label
        let mnemonicWords = mnemonic.components(separatedBy: " ")
        saveMnemonicScreen.continueButton.tap()
        let firstWordNumber = confirmMnemonicScreen.firstWordNumber
        let secondWordNumber = confirmMnemonicScreen.secondWordNumber
        confirmMnemonicScreen.firstInput.typeText(mnemonicWords[firstWordNumber - 1])
        confirmMnemonicScreen.firstInput.typeText("\n")
        XCTAssertTrue(confirmMnemonicScreen.secondInput.hasFocus)
        confirmMnemonicScreen.secondInput.typeText(mnemonicWords[secondWordNumber - 1])
        confirmMnemonicScreen.confirmButton.tap()
        return mnemonic
    }

    enum CameraOpenOption {
        case input, button
    }

    func givenCameraOpened(with option: CameraOpenOption = .button) {
        let pairWithBrowserScreen = PairWithBrowserExtensionScreen()

        cameraPermissionExpectation = expectation(description: "Alert")
        cameraPermissionExpectation.assertForOverFulfill = false
        handleCameraPermsissionByAllowing()
        switch option {
        case .input:
            pairWithBrowserScreen.qrCodeInput.tap()
        case .button:
            pairWithBrowserScreen.qrCodeButton.tap()
        }
        handleCameraAlerts()
    }

    // - MARK: Alerts handling

    func handleCameraPermsissionByAllowing() {
        cameraPermissionHandler = addUIInterruptionMonitor(withDescription: "Camera access") { [unowned self] alert in
            defer { self.cameraPermissionExpectation.fulfill() }
            guard alert.label.localizedCaseInsensitiveContains("would like to access the camera") else {
                return false
            }
            alert.buttons["OK"].tap()
            return true
        }
    }

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

    func handleErrorAlert(with expectation: XCTestExpectation) {
        errorAlertHandler = addUIInterruptionMonitor(withDescription: "Error Alert") { alert in
            guard alert.label == LocalizedString("onboarding.error.title") else { return false }
            alert.buttons[LocalizedString("onboarding.fatal.ok")].tap()
            expectation.fulfill()
            return true
        }
    }

    func assureFatalErrorAlertIsShown(with expectation: XCTestExpectation) {
        errorAlertHandler = addUIInterruptionMonitor(withDescription: "Error Alert") { alert in
            guard alert.label == LocalizedString("onboarding.fatal.title") else { return false }
            alert.buttons[LocalizedString("onboarding.fatal.ok")].tap()
            expectation.fulfill()
            return true
        }
    }

    func handleCameraAlerts() {
        let cameraScreen = CameraScreen()
        delay(1)
        XCUIApplication().swipeUp() // required for alert handlers firing
        if cameraScreen.isDisplayed {
            cameraPermissionExpectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func handleAlerts() {
        delay(1)
        XCUIApplication().swipeUp() // required for alert handlers firing
        waitForExpectations(timeout: 5)
    }

}
