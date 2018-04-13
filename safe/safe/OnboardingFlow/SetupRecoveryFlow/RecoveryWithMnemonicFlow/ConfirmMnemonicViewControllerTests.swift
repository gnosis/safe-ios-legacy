//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe
import IdentityAccessDomainModel
import CommonTestSupport

class ConfirmMnemonicViewControllerTests: XCTestCase {

    // swiftlint:disable weak_delegate
    private let delegate = MockConfirmMnemonicDelegate()
    private var controller: ConfirmMnemonicViewController!
    private let mnemonic = Mnemonic("some mnemonic with several words")

    override func setUp() {
        super.setUp()
        createController(mnemonic)
    }

    func test_canCreate() {
        XCTAssertNotNil(controller)
        XCTAssertNotNil(controller.titleLabel)
        XCTAssertNotNil(controller.descriptionLabel)
        XCTAssertNotNil(controller.firstWordTextInput)
        XCTAssertNotNil(controller.secondWordTextInput)
        XCTAssertNotNil(controller.firstWordTextInput)
        XCTAssertNotNil(controller.secondWordTextInput)
        XCTAssertNotNil(controller.confirmButton)
        XCTAssertTrue(controller.delegate === delegate)
        XCTAssertEqual(mnemonic, controller.mnemonic)
    }

    func test_viewDidLoad_setsRandomCheckingWords() {
        assertRandomWords()
        let smallMnemonic = Mnemonic("two words")
        createController(smallMnemonic)
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
        let mnemonic = Mnemonic("word")
        createController(mnemonic)
        createWindow(controller)
        controller.viewDidLoad()
        delay(1)
        XCTAssertNil(controller.view.window)
    }

    func test_viewDidLoad_setsCorrectWordsLabelText() {
        controller.viewDidLoad()
        let firstWordIndex = mnemonic.words.index(of: controller.firstMnemonicWordToCheck)!
        let secondWordIndex = mnemonic.words.index(of: controller.secondMnemonicWordToCheck)!
        XCTAssertEqual("\(firstWordIndex + 1).", controller.firstWordNumberLabel.text)
        XCTAssertEqual("\(secondWordIndex + 1).", controller.secondWordNumberLabel.text)
    }

}

extension ConfirmMnemonicViewControllerTests {

    private func createController(_ mnemonic: Mnemonic) {
        controller = ConfirmMnemonicViewController.create(delegate: delegate, mnemonic: mnemonic)
        controller.loadViewIfNeeded()
    }

    private func createWindow(_ controller: UIViewController) {
        guard let window = UIApplication.shared.keyWindow else {
            XCTFail("Must have active window")
            return
        }
        window.rootViewController?.present(controller, animated: false)
        delay()
        XCTAssertNotNil(controller.view.window)
    }

    private func assertRandomWords() {
        for _ in 0...100 {
            controller.viewDidLoad()
            XCTAssertNotEqual(controller.firstMnemonicWordToCheck, controller.secondMnemonicWordToCheck)
            XCTAssertTrue(controller.mnemonic.words.contains(controller.firstMnemonicWordToCheck))
            XCTAssertTrue(controller.mnemonic.words.contains(controller.secondMnemonicWordToCheck))
        }
    }

}

final class MockConfirmMnemonicDelegate: ConfirmMnemonicDelegate {

    var confirmed = false

    func didConfirm() {
        confirmed = true
    }

}
