//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import CommonTestSupport
import EthereumApplication

class ConfirmMnemonicViewControllerTests: SafeTestCase {

    // swiftlint:disable:next weak_delegate
    private let delegate = MockConfirmMnemonicDelegate()
    private var controller: ConfirmMnemonicViewController!
    private var words = ["some", "random", "words", "from", "a", "mnemonic"]

    override func setUp() {
        super.setUp()
        createController(words: words)
    }

    func test_canCreate() {
        XCTAssertNotNil(controller)
        XCTAssertNotNil(controller.titleLabel)
        XCTAssertNotNil(controller.descriptionLabel)
        XCTAssertNotNil(controller.firstWordTextInput)
        XCTAssertTrue(controller.firstWordTextInput.delegate === controller)
        XCTAssertNotNil(controller.secondWordTextInput)
        XCTAssertTrue(controller.secondWordTextInput.delegate === controller)
        XCTAssertNotNil(controller.firstWordTextInput)
        XCTAssertNotNil(controller.secondWordTextInput)
        XCTAssertTrue(controller.delegate === delegate)
        XCTAssertEqual(words, controller.words)
    }

    func test_viewDidLoad_setsRandomCheckingWords() {
        assertRandomWords()
        createController(words: ["two", "words"])
        assertRandomWords()
    }

    func test_viewDidLoad_dismissesIfMnemonicIsNil() throws {
        let controller = ConfirmMnemonicViewController()
        createWindow(controller)
        controller.viewDidLoad()
        delay(1)
        XCTAssertNil(controller.view.window)
    }

    func test_viewDidLoad_dismissesIfMnemonicHasLessThanTwoWords() throws {
        createController(words: ["word"])
        createWindow(controller)
        controller.viewDidLoad()
        delay(1)
        XCTAssertNil(controller.view.window)
    }

    func test_viewDidLoad_setsCorrectWordsLabelText() {
        controller.viewDidLoad()
        let firstWordIndex = words.index(of: controller.firstMnemonicWordToCheck)!
        let secondWordIndex = words.index(of: controller.secondMnemonicWordToCheck)!
        XCTAssertEqual("#\(firstWordIndex + 1).", controller.firstWordNumberLabel.text)
        XCTAssertEqual("#\(secondWordIndex + 1).", controller.secondWordNumberLabel.text)
    }

    func test_viewDidLoad_setsFirstTextInputAsFirstResponder() {
        createWindow(controller)
        controller.viewDidLoad()
        XCTAssertTrue(controller.firstWordTextInput.isActive)
    }

    func test_whenTextInputsHaveWrongWords_thenDelegateIsNotCalled() {
        setTextInputs("wrong", controller.secondMnemonicWordToCheck)
        XCTAssertFalse(delegate.confirmed)
        setTextInputs(controller.firstMnemonicWordToCheck, "wrong")
        XCTAssertFalse(delegate.confirmed)
    }

    func test_whenTextInputsHaveCorrectWords_thenDelegateIsCalled() {
        setTextInputs(controller.firstMnemonicWordToCheck, controller.secondMnemonicWordToCheck)
        XCTAssertTrue(delegate.confirmed)
    }

    func test_textInputDidReturn_whenTriggeredByFirstInput_thenSetsSecondInputAsFirstResponder() {
        createWindow(controller)
        controller.textInputDidReturn(controller.firstWordTextInput)
        XCTAssertTrue(controller.secondWordTextInput.isActive)
    }

    func test_whenTextInputReturns_thenAddsOwner() throws {
        try walletService.createNewDraftWallet()
        setTextInputs(controller.firstMnemonicWordToCheck, controller.secondMnemonicWordToCheck)
        XCTAssertEqual(walletService.ownerAddress(of: .paperWallet), "address")
    }

}

extension ConfirmMnemonicViewControllerTests {

    private func setTextInputs(_ first: String, _ second: String) {
        controller.firstWordTextInput.text = first
        controller.secondWordTextInput.text = second
        controller.textInputDidReturn(controller.secondWordTextInput)
    }

    private func createController(words: [String]) {
        let account = ExternallyOwnedAccountData(address: "address", mnemonicWords: words)
        controller = ConfirmMnemonicViewController.create(delegate: delegate, account: account)
        controller.loadViewIfNeeded()
    }

    private func assertRandomWords() {
        for _ in 0...100 {
            controller.viewDidLoad()
            XCTAssertNotEqual(controller.firstMnemonicWordToCheck, controller.secondMnemonicWordToCheck)
            XCTAssertTrue(controller.words.contains(controller.firstMnemonicWordToCheck))
            XCTAssertTrue(controller.words.contains(controller.secondMnemonicWordToCheck))
        }
    }

}

final class MockConfirmMnemonicDelegate: ConfirmMnemonicDelegate {

    var confirmed = false

    func didConfirm() {
        confirmed = true
    }

}
