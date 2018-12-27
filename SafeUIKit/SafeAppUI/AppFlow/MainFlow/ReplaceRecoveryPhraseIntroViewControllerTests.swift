//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import MultisigWalletApplication
import Common

class ReplaceRecoveryPhraseIntroViewControllerTests: XCTestCase {

    let service = MockWalletSettingsApplicationService()
    var vc: ReplaceRecoveryPhraseIntroViewController!

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: service, for: WalletSettingsApplicationService.self)
        vc = ReplaceRecoveryPhraseIntroViewController.create()
    }

    func test_whenCreated_thenInitialState() {
        XCTAssertEqual(vc.state, .initial)
    }

    func test_whenViewLoaded_thenEntersInitialState() {
        service.expect_createRecoveryPhraseTransaction(returns: .testData)
        enter(.initial)
        waitUntil(vc.transaction != nil, timeout: 0.1)
        service.verify()
    }

    // MARK: Initial state

    func test_whenInInitialState_thenDisablesEverything() {
        service.expect_createRecoveryPhraseTransaction(returns: .testData, delay: 1)
        enter(.initial)
        XCTAssertDisabled(vc.cancelButtonItem)
        XCTAssertDisabled(vc.startButtonItem)
        AssertStatusTextEqual(ReplaceRecoveryPhraseIntroViewController.InitialState.Strings.status)
    }

    func test_whenCreatedRecoveryTransaction_thenTransitionsToLoadingState() {
        service.expect_createRecoveryPhraseTransaction(returns: .testData)
        enter(.initial)
        waitUntil(vc.state == .loading, timeout: 0.1)
    }

    func test_whenTransactionAssigned_thenDoesNotQueryService() {
        vc.transaction = .testData
        enter(.initial)
        service.verify()
    }

    func test_whenInInitialState_thenShowsCancelAndStart() {
        vc.transaction = .testData
        enter(.initial)
        XCTAssertEqual(vc.navigationItem.leftBarButtonItems, [vc.cancelButtonItem])
        XCTAssertEqual(vc.navigationItem.rightBarButtonItems, [vc.startButtonItem])
    }

    // MARK: Loading state

    func test_whenInLoadingState_thenEnablesCancel() {
        vc.cancelButtonItem.isEnabled = false
        enter(.loading)
        XCTAssertEnabled(vc.cancelButtonItem)
    }

    func test_whenInLoadingState_thenStartActivityIndicator() {
        vc.cancelButtonItem.isEnabled = false
        enter(.loading)
        XCTAssertAnimating(vc.activityIndicator)
    }

    func test_whenInLoadingState_thenDisablesStart() {
        vc.startButtonItem.isEnabled = true
        enter(.loading)
        XCTAssertDisabled(vc.startButtonItem)
    }

    func test_whenInLoadingState_thenDisplaysStatusMessage() {
        enter(.loading)
        AssertStatusTextEqual(ReplaceRecoveryPhraseIntroViewController.LoadingState.Strings.status)
    }

    func test_whenInLoadingState_thenReloadsTransaction() {
    }

    func test_whenLoadingFails_thenTransitionsToErrorState() {
    }

    func test_whenAfterLoadingFundsNeeded_thenTransitionsToInsufficientFundsState() {
    }

    func test_whenAfterLoadingAllIsGood_thenTransitionsToReadyState() {
    }

    func test_whenDuringLoadingUserCancels_thenTransitionsToCancelledState() {
    }

}

extension ReplaceRecoveryPhraseIntroViewControllerTests {

    private func enter(_ state: ReplaceRecoveryPhraseIntroViewController.State.StateType) {
        vc.state = state
        vc.loadViewIfNeeded()
    }

    private func AssertStatusTextEqual(_ expectedStatus: String,
                                       _ file: StaticString = #file,
                                       _ line: UInt = #line) {
        XCTAssertEqual(vc.statusText, expectedStatus, file: file, line: line)
    }

}

protocol Enablable {
    var isEnabled: Bool { get }
}

extension UIBarItem: Enablable {}
extension UIAlertAction: Enablable {}
extension UIControl: Enablable {}
extension UIGestureRecognizer: Enablable {}
extension UILabel: Enablable {}
extension UIDragInteraction: Enablable {}
extension UIFocusGuide: Enablable {}
@available(iOS 12.1, *)
extension UIPencilInteraction: Enablable {}

func XCTAssertEnabled(_ item: Enablable, _ message: String = "", _ file: StaticString = #file, _ line: UInt = #line) {
    XCTAssertTrue(item.isEnabled, "Expected \(item) to be enabled. \(message)", file: file, line: line)
}

func XCTAssertDisabled(_ item: Enablable, _ message: String = "", _ file: StaticString = #file, _ line: UInt = #line) {
    XCTAssertFalse(item.isEnabled, "Expected \(item) to be disabled. \(message)", file: file, line: line)
}

protocol Animatable {
    var isAnimating: Bool { get }
}

extension UIActivityIndicatorView: Animatable {}
extension UIImageView: Animatable {}

func XCTAssertAnimating(_ item: Animatable,
                        _ message: String = "",
                        _ file: StaticString = #file,
                        _ line: UInt = #line) {
    XCTAssertTrue(item.isAnimating, "Expected \(item) to be animating. \(message)", file: file, line: line)
}

func XCTAssertNotAnimating(_ item: Animatable,
                           _ message: String = "",
                           _ file: StaticString = #file,
                           _ line: UInt = #line) {
    XCTAssertFalse(item.isAnimating, "Expected \(item) not to be animating. \(message)", file: file, line: line)
}

fileprivate extension TokenData {

    static let `default` = TokenData(address: "",
                                     code: "",
                                     name: "",
                                     logoURL: "",
                                     decimals: 10,
                                     balance: nil)
}

fileprivate extension TransactionData {

    static let testData = TransactionData(id: "TransactionID_123",
                                          sender: "",
                                          recipient: "",
                                          amountTokenData: .default,
                                          feeTokenData: .default,
                                          status: .pending,
                                          type: .replaceRecoveryPhrase,
                                          created: nil,
                                          updated: nil,
                                          submitted: nil,
                                          rejected: nil,
                                          processed: nil)
}


class MockWalletSettingsApplicationService: WalletSettingsApplicationService {

    private var expected_createRecoveryPhraseTransaction_invocation =
        [(returns: TransactionData, delay: TimeInterval)]()
    private var actual_createRecoveryPhraseTransaction_invocations = [String]()

    func expect_createRecoveryPhraseTransaction(returns data: TransactionData, delay: TimeInterval = 0) {
        expected_createRecoveryPhraseTransaction_invocation.append((data, delay))
    }

    override func createRecoveryPhraseTransaction() -> TransactionData {
        actual_createRecoveryPhraseTransaction_invocations.append(#function)
        let index = actual_createRecoveryPhraseTransaction_invocations.count - 1
        assert(index < expected_createRecoveryPhraseTransaction_invocation.count, "Unexpected call to \(#function)")
        let invocation = expected_createRecoveryPhraseTransaction_invocation[index]
        if invocation.delay > 0 {
            usleep(useconds_t(invocation.delay * 1_000))
        }
        return invocation.returns
    }

    func verify(file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(actual_createRecoveryPhraseTransaction_invocations.count,
                       expected_createRecoveryPhraseTransaction_invocation.count,
                       "Actual invocations of createRecoveryPhraseTransaction() did not match expectations",
                       file: file,
                       line: line)
    }

}
