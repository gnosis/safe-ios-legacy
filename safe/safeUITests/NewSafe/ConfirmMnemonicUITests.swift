//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
import CommonTestSupport

final class ConfirmMnemonicUITests: UITestCase {

    let confirmMnemonicScreen = ConfirmMnemonicScreen()
    let saveMnemonicScreen = SaveMnemonicScreen()
    let newSafeScreen = NewSafeScreen()
    let setupSafeOptionsScreen = SetupSafeOptionsScreen()

    override func setUp() {
        super.setUp()
        givenConfirmMnemonicSetup()
    }

    // NS-104
    func test_contents() {
        XCTAssertTrue(confirmMnemonicScreen.isDisplayed)
        XCTAssertExist(confirmMnemonicScreen.description)
        XCTAssertExist(confirmMnemonicScreen.firstInput)
        XCTAssertExist(confirmMnemonicScreen.secondInput)
        XCTAssertTrue(confirmMnemonicScreen.firstInput.hasFocus)
        XCTAssertFalse(confirmMnemonicScreen.secondInput.hasFocus)
        XCTAssertExist(confirmMnemonicScreen.firstWordNumberLabel)
        XCTAssertExist(confirmMnemonicScreen.secondWordNumberLabel)
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
        let firstWordNumber = wordNumber(from: confirmMnemonicScreen.firstWordNumberLabel.label)
        let secondWordNumber = wordNumber(from: confirmMnemonicScreen.secondWordNumberLabel.label)
        TestUtils.navigateBack()
        saveMnemonicScreen.continueButton.tap()
        let newFirstWordNumber = wordNumber(from: confirmMnemonicScreen.firstWordNumberLabel.label)
        let newSecondWordNumber = wordNumber(from: confirmMnemonicScreen.secondWordNumberLabel.label)
        XCTAssertFalse(firstWordNumber == newFirstWordNumber && secondWordNumber == newSecondWordNumber)
    }

    // NS-107, NS-108, NS-109
    func test_whenPaperWalletRevalidated_thenItIsStillConfigured() {
        confirmPaperWalletWithValidWords()
        newSafeScreen.paperWallet.element.tap()
        saveMnemonicScreen.continueButton.tap()
        assertPaperWalletIsSet()
        TestUtils.navigateBack()
        setupSafeOptionsScreen.newSafe.tap()
        assertPaperWalletIsSet()
    }

    // NS-107-01, NS-110
    func test_restartingAppInvalidatesConfiguredPaperWallet() {
        let mnemonic = confirmPaperWalletWithValidWords(withConfirmButton: true)
        Application().terminate()
        givenNewSafeSetup(withAppReset: false)
        XCTAssertTrue(newSafeScreen.isDisplayed)
        XCTAssertTrue(newSafeScreen.paperWallet.isChecked)
        newSafeScreen.paperWallet.element.tap()
        XCTAssertEqual(mnemonic, saveMnemonicScreen.mnemonic.label)
    }

    private func wordNumber(from label: String) -> Int {
        let regexp = try! NSRegularExpression(pattern: "\\d+")
        let match = regexp.firstMatch(in: label, range: NSRange(location: 0, length: label.count))
        let result = (label as NSString).substring(with: match!.range)
        return Int(result)!
    }

    @discardableResult
    private func confirmPaperWalletWithValidWords(withConfirmButton: Bool = false) -> String {
        TestUtils.navigateBack()
        let mnemonic = saveMnemonicScreen.mnemonic.label
        let mnemonicWords = mnemonic.components(separatedBy: " ")
        saveMnemonicScreen.continueButton.tap()
        let firstWordNumber = wordNumber(from: confirmMnemonicScreen.firstWordNumberLabel.label)
        let secondWordNumber = wordNumber(from: confirmMnemonicScreen.secondWordNumberLabel.label)
        confirmMnemonicScreen.firstInput.typeText(mnemonicWords[firstWordNumber - 1])
        confirmMnemonicScreen.firstInput.typeText("\n")
        XCTAssertTrue(confirmMnemonicScreen.secondInput.hasFocus)
        confirmMnemonicScreen.secondInput.typeText(mnemonicWords[secondWordNumber - 1])
        if withConfirmButton {
            confirmMnemonicScreen.confirmButton.tap()
        } else {
            confirmMnemonicScreen.secondInput.typeText("\n")
        }
        assertPaperWalletIsSet()
        return mnemonic
    }

    private func assertPaperWalletIsSet() {
        XCTAssertTrue(newSafeScreen.isDisplayed)
        XCTAssertTrue(newSafeScreen.paperWallet.isChecked)
    }

}
