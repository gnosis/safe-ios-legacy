//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe
import IdentityAccessDomainModel
import CommonTestSupport

class SaveMnemonicViewControllerTests: SafeTestCase {

    // swiftlint:disable weak_delegate
    private let delegate = MockSaveMnemonicDelegate()
    private var controller: SaveMnemonicViewController!

    override func setUp() {
        super.setUp()
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

    func test_viewDidLoad_setsCorrectMnemonic() throws {
        let mnemonicStr = "test mnemonic"
        let mnemonic = Mnemonic(mnemonicStr)
        try secureStore.saveMnemonic(mnemonic)
        controller.viewDidLoad()
        XCTAssertEqual(controller.mnemonicCopyableLabel.text, mnemonicStr)
        XCTAssertEqual(controller.words, mnemonic.words)
    }

    func test_viewDidLoad_dismissesIfNoEOAisSet() throws {
        try secureStore.removeMnemonic()
        guard let window = UIApplication.shared.keyWindow else {
            XCTFail("Must have active window")
            return
        }
        window.rootViewController?.present(controller, animated: false)
        delay()
        XCTAssertNotNil(controller.view.window)
        controller.viewDidLoad()
        delay(1)
        XCTAssertNil(controller.view.window)
    }

    func test_continuePressed_callsDelegate() throws {
        let mnemonicWords = ["test", "mnemonic"]
        try secureStore.saveMnemonic(Mnemonic(mnemonicWords))
        controller.viewDidLoad()
        controller.continuePressed(self)
        XCTAssertEqual(delegate.mnemonicWords, mnemonicWords)
    }

}

final class MockSaveMnemonicDelegate: SaveMnemonicDelegate {

    var mnemonicWords: [String] = []

    func didPressContinue(mnemonicWords: [String]) {
        self.mnemonicWords = mnemonicWords
    }

}
