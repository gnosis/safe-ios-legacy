//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest

class UITestCase: XCTestCase {

    let application = Application()
    let password = "11111A"

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
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

}
