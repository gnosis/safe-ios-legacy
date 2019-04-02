//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import CommonTestSupport
import MultisigWalletApplication

class TimeProfiler {

    typealias Point = (line: UInt, time: Date)
    typealias Diff = (current: Point, next: Point, diff: TimeInterval)
    let timeFormatter = NumberFormatter()
    var points = [Point]()

    init() {
        timeFormatter.numberStyle = .decimal
    }

    func checkpoint(line: UInt = #line) {
        points.append((line, Date()))
    }

    func summary() -> String {
        let diffs = (0..<points.count - 1).map { index -> Diff in
            let next = points[index + 1]
            let current = points[index]
            let diff = next.time.timeIntervalSinceReferenceDate - current.time.timeIntervalSinceReferenceDate
            return (current, next, diff)
        }.sorted { a, b -> Bool in
            a.diff > b.diff
        }.map { diff -> String in
            "\(diff.next.line)-\(diff.current.line): \(timeFormatter.string(from: NSNumber(value: diff.diff))!)"
        }
        return diffs.joined(separator: "\n")
    }
}

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
        XCTAssertNotNil(controller.headerLabel)
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
        let firstWordIndex = words.firstIndex(of: controller.firstMnemonicWordToCheck)!
        let secondWordIndex = words.firstIndex(of: controller.secondMnemonicWordToCheck)!
        XCTAssertEqual(controller.firstWordTextInput.textInput.placeholder, "Word #\(firstWordIndex + 1)")
        XCTAssertEqual(controller.secondWordTextInput.textInput.placeholder, "Word #\(secondWordIndex + 1)")
    }

    func test_viewDidLoad_setsFirstTextInputAsFirstResponder() {
        createWindow(controller)
        controller.viewDidLoad()
        XCTAssertTrue(controller.firstWordTextInput.isActive)
    }

    func test_whenTextInputsHaveWrongWords_thenDelegateIsNotCalled() {
        typeIntoTextInputs("wrong", controller.secondMnemonicWordToCheck)
        XCTAssertFalse(delegate.confirmed)
        typeIntoTextInputs(controller.firstMnemonicWordToCheck, "wrong")
        XCTAssertFalse(delegate.confirmed)
    }

    func test_whenTextInputsHaveCorrectWords_thenDelegateIsCalled() {
        let expectedEOA = ExternallyOwnedAccountData(address: "derived",
                                                     mnemonicWords: controller.account.mnemonicWords)
        ethereumService.expect_generateDerivedExternallyOwnedAccount(address: controller.account.address,
                                                                     expectedEOA)
        typeIntoTextInputs(controller.firstMnemonicWordToCheck, controller.secondMnemonicWordToCheck)
        XCTAssertTrue(delegate.confirmed)
    }

    func test_textInputDidReturn_whenTriggeredByFirstInput_thenSetsSecondInputAsFirstResponder() {
        createWindow(controller)
        controller.verifiableInputDidReturn(controller.firstWordTextInput)
        XCTAssertTrue(controller.secondWordTextInput.isActive)
    }

    func test_whenTextInputReturns_thenAddsOwner() {
        walletService.createNewDraftWallet()
        let expectedEOA = ExternallyOwnedAccountData(address: "derived",
                                                     mnemonicWords: controller.account.mnemonicWords)
        ethereumService.expect_generateDerivedExternallyOwnedAccount(address: controller.account.address,
                                                                     expectedEOA)
        typeIntoTextInputs(controller.firstMnemonicWordToCheck, controller.secondMnemonicWordToCheck)
        XCTAssertEqual(walletService.ownerAddress(of: .paperWallet), "address")
        XCTAssertEqual(walletService.ownerAddress(of: .paperWalletDerived), "derived")
    }

}

extension ConfirmMnemonicViewControllerTests {

    private func typeIntoTextInputs(_ first: String, _ second: String) {
        controller.firstWordTextInput.text = first
        controller.secondWordTextInput.text = second
        controller.verifiableInputDidReturn(controller.secondWordTextInput)
    }

    private func createController(words: [String]) {
        let account = ExternallyOwnedAccountData(address: "address", mnemonicWords: words)
        controller = ConfirmMnemonicViewController.create(delegate: delegate, account: account)
        controller.loadViewIfNeeded()
    }

    private func assertRandomWords() {
        for _ in 0...100 {
            let words = controller.twoRandomWords()
            XCTAssertNotEqual(words.0, words.1)
            XCTAssertTrue(controller.words.contains(words.0))
            XCTAssertTrue(controller.words.contains(words.1))
        }
    }

}

final class MockConfirmMnemonicDelegate: ConfirmMnemonicDelegate {

    var confirmed = false

    func confirmMnemonicViewControllerDidConfirm(_ vc: ConfirmMnemonicViewController) {
        confirmed = true
    }

}
