//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import IdentityAccessDomainModel
import CommonTestSupport
import EthereumApplication

class SaveMnemonicViewControllerTests: SafeTestCase {

    // swiftlint:disable:next weak_delegate
    private let delegate = MockSaveMnemonicDelegate()
    private var controller: SaveMnemonicViewController!
    private var words = ["test", "mnemonic"]

    override func setUp() {
        super.setUp()
        ethereumService.prepareToGenerateExternallyOwnedAccount(address: "address", mnemonic: words)
        controller = SaveMnemonicViewController.create(delegate: delegate)
        controller.loadViewIfNeeded()
    }

    func test_canCreate() {
        XCTAssertNotNil(controller)
        XCTAssertNotNil(controller.titleLabel)
        XCTAssertNotNil(controller.mnemonicCopyableLabel)
        XCTAssertNotNil(controller.saveButton)
        XCTAssertNotNil(controller.descriptionLabel)
        XCTAssertNotNil(controller.continueButton)
        XCTAssertTrue(controller.delegate === delegate)
    }

    func test_whenNoPaperWalletExists_thenDisplaysGeneratedMnemonicWords() throws {
        try walletService.createNewDraftWallet()
        let mnemonicStr = words.joined(separator: " ")
        XCTAssertEqual(controller.mnemonicCopyableLabel.text, mnemonicStr)
    }

    func test_viewDidLoad_dismissesIfNoWordsProvided() {
        ethereumService.prepareToGenerateExternallyOwnedAccount(address: "address", mnemonic: [])
        controller = SaveMnemonicViewController.create(delegate: delegate)
        createWindow(controller)
        controller.viewDidLoad()
        delay(1)
        XCTAssertNil(controller.view.window)
    }

    func test_continuePressed_callsDelegate() throws {
        controller.continuePressed(self)
        XCTAssertTrue(delegate.pressedContinue)
    }

    func test_whenEOAGenerationFails_thenShowsErrorAlert() {
        ethereumService.shouldThrow = true
        controller = SaveMnemonicViewController.create(delegate: delegate)
        createWindow(controller)
        delay(1)
        XCTAssertAlertShown()
    }

    func test_whenPaperWalletExists_thenItIsDisplayed() throws {
        try walletService.createNewDraftWallet()
        walletService.addOwner(address: "some", type: .paperWallet)
        let expectedMnemonic = ["one", "two", "three"]
        let expectedAccount = ExternallyOwnedAccountData(address: "some", mnemonicWords: expectedMnemonic)
        ethereumService.addExternallyOwnedAccount(expectedAccount)
        let generatedMnemonic = ["alpha", "beta", "gamma"]
        ethereumService.prepareToGenerateExternallyOwnedAccount(address: "newAddress", mnemonic: generatedMnemonic)
        controller = SaveMnemonicViewController.create(delegate: delegate)
        controller.loadViewIfNeeded()
        XCTAssertEqual(controller.account, expectedAccount)
    }

}

final class MockSaveMnemonicDelegate: SaveMnemonicDelegate {

    var pressedContinue = false

    func didPressContinue() {
        pressedContinue = true
    }

}
