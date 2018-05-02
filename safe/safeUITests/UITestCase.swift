//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest

class UITestCase: XCTestCase {

    let application = Application()
    let password = "11111A"
    let newSafe = NewSafeScreen()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func givenUnlockedAppSetup() {
        application.resetAllContentAndSettings()
        application.setPassword(password)
        application.start()
        let unlock = UnlockScreen()
        unlock.enterPassword(password)
    }

    func givenNewSafeSetup() {
        givenUnlockedAppSetup()
        let setupOptions = SetupSafeOptionsScreen()
        setupOptions.newSafe.tap()
    }

    func givenBrowserExtensionSetup() {
        givenNewSafeSetup()
        newSafe.browserExtension.element.tap()
    }

    func givenPaperWalletSetup() {
        givenNewSafeSetup()
        newSafe.paperWallet.element.tap()
    }

}
