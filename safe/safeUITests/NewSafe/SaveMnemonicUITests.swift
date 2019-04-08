//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
import CommonTestSupport

final class SaveMnemonicUITests: UITestCase {

    let saveMnemonicScreen = SaveMnemonicScreen()

    override func setUp() {
        super.setUp()
        givenSaveMnemonicSetup()
    }

    // NS-101
    func test_contents() {
        XCTAssertTrue(saveMnemonicScreen.isDisplayed)
        XCTAssertEqual(saveMnemonicScreen.description.label, LocalizedString("new_safe.setup_recovery.description"))
        XCTAssertExist(saveMnemonicScreen.mnemonic)
        XCTAssertExist(saveMnemonicScreen.copyButton)
        XCTAssertExist(saveMnemonicScreen.continueButton)
    }

    // NS-102
    func test_copyMnemonic() {
        let mnemonic = saveMnemonicScreen.mnemonic.label
        saveMnemonicScreen.copyButton.tap()
        saveMnemonicScreen.continueButton.tap()
        let confirmScreen = ConfirmMnemonicScreen()
        confirmScreen.firstInput.tap()
        XCUIApplication().menuItems["Paste"].tap()
        delay(0.5) // paste animation
        let pastedValue = confirmScreen.firstInput.value as! String
        XCTAssertEqual(pastedValue, mnemonic)
    }

}
