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

    func test_whenNavigatingBackAndForward_checkingWordsAreAlwaysDifferent() {
        let firstWordNumber = wordNumber(from: confirmMnemonicScreen.firstWordNumberLabel.label)
        let secondWordNumber = wordNumber(from: confirmMnemonicScreen.secondWordNumberLabel.label)
        TestUtils.navigateBack()
        saveMnemonicScreen.continueButton.tap()
        let newFirstWordNumber = wordNumber(from: confirmMnemonicScreen.firstWordNumberLabel.label)
        let newSecondWordNumber = wordNumber(from: confirmMnemonicScreen.secondWordNumberLabel.label)
        XCTAssertFalse(firstWordNumber == newFirstWordNumber && secondWordNumber == newSecondWordNumber)
    }

    func test_whenPaperWalletRevalidated_thenItIsStillConfigured() {
        confirmPaperWalletWithValidWords()
        reValidate()
        navidateBackAndForward()
    }

    func test_restartingAppInvalidatesConfiguredPaperWallet() {
        confirmPaperWalletWithValidWords()
        Application().terminate()
        givenNewSafeSetup(withAppReset: false)
        XCTAssertTrue(newSafeScreen.isDisplayed)
        XCTAssertFalse(newSafeScreen.paperWallet.isChecked)
    }

    private func wordNumber(from label: String) -> Int {
        let regexp = try! NSRegularExpression(pattern: "\\d+")
        let match = regexp.firstMatch(in: label, range: NSRange(location: 0, length: label.count))
        let result = (label as NSString).substring(with: match!.range)
        return Int(result)!
    }

    private func confirmPaperWalletWithValidWords() {
        TestUtils.navigateBack()
        let mnemonicWords = saveMnemonicScreen.mnemonic.label.components(separatedBy: " ")
        saveMnemonicScreen.continueButton.tap()
        let firstWordNumber = wordNumber(from: confirmMnemonicScreen.firstWordNumberLabel.label)
        let secondWordNumber = wordNumber(from: confirmMnemonicScreen.secondWordNumberLabel.label)
        confirmMnemonicScreen.firstInput.typeText(mnemonicWords[firstWordNumber - 1])
        confirmMnemonicScreen.firstInput.typeText("\n")
        XCTAssertTrue(confirmMnemonicScreen.secondInput.hasFocus)
        confirmMnemonicScreen.secondInput.typeText(mnemonicWords[secondWordNumber - 1])
        confirmMnemonicScreen.secondInput.typeText("\n")
        assertPaperWalletIsSet()
    }

    private func reValidate() {
        newSafeScreen.paperWallet.element.tap()
        saveMnemonicScreen.continueButton.tap()
        assertPaperWalletIsSet()
    }

    private func navidateBackAndForward() {
        TestUtils.navigateBack()
        setupSafeOptionsScreen.newSafe.tap()
        assertPaperWalletIsSet()
    }

    private func assertPaperWalletIsSet() {
        XCTAssertTrue(newSafeScreen.isDisplayed)
        XCTAssertTrue(newSafeScreen.paperWallet.isChecked)
    }

}
