//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
import CommonTestSupport

class UITestCase: XCTestCase {

    let application = Application()
    let password = "11111A"
    private var cameraPermissionHandler: NSObjectProtocol!
    private var cameraPermissionExpectation: XCTestExpectation!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    override func tearDown() {
        if let handler = cameraPermissionHandler {
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
        handleAlerts()
    }

    private func handleCameraPermsissionByAllowing() {
        cameraPermissionHandler = addUIInterruptionMonitor(withDescription: "Camera access") { [unowned self] alert in
            defer { self.cameraPermissionExpectation.fulfill() }
            guard alert.label.localizedCaseInsensitiveContains("would like to access the camera") else {
                return false
            }
            alert.buttons["OK"].tap()
            return true
        }
    }

    private func handleAlerts() {
        let cameraScreen = CameraScreen()
        delay(1)
        XCUIApplication().tap() // required for alert handlers firing
        if cameraScreen.isDisplayed {
            cameraPermissionExpectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

}
