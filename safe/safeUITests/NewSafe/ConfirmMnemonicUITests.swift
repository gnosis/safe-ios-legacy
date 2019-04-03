//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
import CommonTestSupport

final class ConfirmMnemonicUITests: UITestCase {

    let confirmMnemonicScreen = ConfirmMnemonicScreen()
    let saveMnemonicScreen = SaveMnemonicScreen()
    let newSafeScreen = NewSafeScreen()

    override func setUp() {
        super.setUp()
        givenConfirmMnemonicSetup()
    }

    // NS-104
    func test_contents() {
        XCTAssertTrue(confirmMnemonicScreen.isDisplayed)
        XCTAssertExist(confirmMnemonicScreen.firstInput)
        XCTAssertExist(confirmMnemonicScreen.secondInput)
        XCTAssertTrue(confirmMnemonicScreen.firstInput.hasFocus)
        XCTAssertFalse(confirmMnemonicScreen.secondInput.hasFocus)
    }

    // NS-105
    func test_whenTryingToConfirmWithInvalidWords_thenNothingHappens() {
        confirmMnemonicScreen.firstInput.typeText("\n")
        confirmMnemonicScreen.secondInput.typeText("\n")
        delay()
        XCTAssertTrue(confirmMnemonicScreen.isDisplayed)
        confirmMnemonicScreen.confirmButton.tap()
        delay()
        XCTAssertTrue(confirmMnemonicScreen.isDisplayed)
    }

    // NS-106
    func test_whenNavigatingBackAndForward_checkingWordsAreAlwaysDifferent() {
        let firstWordNumber = confirmMnemonicScreen.firstWordNumber
        let secondWordNumber = confirmMnemonicScreen.secondWordNumber
        confirmMnemonicScreen.backButton.tap()
        saveMnemonicScreen.continueButton.tap()
        let newFirstWordNumber = confirmMnemonicScreen.firstWordNumber
        let newSecondWordNumber = confirmMnemonicScreen.secondWordNumber
        XCTAssertFalse(firstWordNumber == newFirstWordNumber && secondWordNumber == newSecondWordNumber)
    }

    // NS-107, NS-108, NS-109
    func test_whenPaperWalletRevalidated_thenItIsStillConfigured() {
        confirmMnemonicScreen.backButton.tap()
        confirmPaperWalletWithValidWords()
        assertPaperWalletIsSet()
        newSafeScreen.paperWallet.element.tap()
        saveMnemonicScreen.continueButton.tap()
        assertPaperWalletIsSet()
        saveMnemonicScreen.backButton.tap()
        NewSafeGuidelinesScreen().nextButton.tap()
        assertPaperWalletIsSet()
    }

    // NS-107-01, NS-110
    func test_restartingAppInvalidatesConfiguredPaperWallet() {
        confirmMnemonicScreen.backButton.tap()
        let mnemonic = confirmPaperWalletWithValidWords(withConfirmButton: true)
        assertPaperWalletIsSet()
        Application().terminate()
        givenNewSafeSetup(withAppReset: false)
        XCTAssertTrue(newSafeScreen.paperWallet.isChecked)
        newSafeScreen.paperWallet.element.tap()
        XCTAssertEqual(mnemonic, saveMnemonicScreen.mnemonic.label)
    }

    private func assertPaperWalletIsSet() {
        XCTAssertTrue(newSafeScreen.isDisplayed)
        XCTAssertTrue(newSafeScreen.paperWallet.isChecked)
    }

}
