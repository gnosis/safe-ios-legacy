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
    private var words = ["test", "mnemonic"]

    override func setUp() {
        super.setUp()
        controller = SaveMnemonicViewController.create(words: words, delegate: delegate)
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

    func test_viewDidLoad_setsCorrectWords() {
        let mnemonicStr = words.joined(separator: " ")
        XCTAssertEqual(controller.words, words)
        XCTAssertEqual(controller.mnemonicCopyableLabel.text, mnemonicStr)
    }

    func test_viewDidLoad_dismissesIfNoWordsProvided() {
        controller = SaveMnemonicViewController.create(words: [], delegate: delegate)
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
        controller.continuePressed(self)
        XCTAssertTrue(delegate.pressedContinue)
    }

}

final class MockSaveMnemonicDelegate: SaveMnemonicDelegate {

    var pressedContinue = false

    func didPressContinue() {
        pressedContinue = true
    }

}
