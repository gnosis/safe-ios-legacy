//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import SafeAppUI
import MultisigWalletApplication
import MultisigWalletDomainModel

class ReplaceTwoFAFlowCoordinatorTests: XCTestCase {

    let nav = UINavigationController()
    var fc: ReplaceTwoFAFlowCoordinator!
    let mockApplicationService = MockReplaceExtensionApplicationService()

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: mockApplicationService,
                                       for: ReplaceTwoFAApplicationService.self)
        fc = TestableReplaceTwoFAFlowCoordinator(rootViewController: nav)
        fc.setUp()
    }

    func test_onEnter_pushesIntro() {
        XCTAssertTrue(nav.topViewController is RBEIntroViewController)
    }

    func test_whenIntroDidStart_thenTakesTransactionID() {
        fc.introVC!.transactionID = "Some"
        fc.rbeIntroViewControllerDidStart()
        XCTAssertEqual(fc.transactionID, "Some")
    }

    func test_whenScannedCode_thenConnects() throws {
        fc.introVC!.transactionID = "Some"
        fc.rbeIntroViewControllerDidStart()
        let vc = AuthenticatorViewController.create(delegate: nil)
        try fc.authenticatorViewController(vc, didScanAddress: "Address", code: "Code")
        XCTAssertTrue(mockApplicationService.didCallConnect)
    }

    func test_whenPairingFinishes_thenPresentsRecoveryPhraseInput() {
        fc.authenticatorViewControllerDidFinish()
        XCTAssertTrue(nav.topViewController is RecoveryPhraseInputViewController)
    }

    func test_whenPhraseEntered_thenSignsTransaction() {
        let vc = RecoveryPhraseInputViewController.create(delegate: fc)
        fc.transactionID = "tx"
        fc.recoveryPhraseInputViewController(vc, didEnterPhrase: "phrase")
        XCTAssertTrue(mockApplicationService.didCallSignTransaction)
    }

    func test_whenSigningThrows_thenHandlesError() {
        let vc = MockRecoveryPhraseInputViewController()
        mockApplicationService.shouldThrow = true
        fc.transactionID = "tx"
        fc.recoveryPhraseInputViewController(vc, didEnterPhrase: "phrase")
        XCTAssertTrue(vc.didHandleError)
    }

    func test_whenSigningOk_thenHandlesSuccess() {
        let vc = MockRecoveryPhraseInputViewController()
        fc.transactionID = "tx"
        fc.recoveryPhraseInputViewController(vc, didEnterPhrase: "phrase")
        XCTAssertTrue(vc.didHandleSuccess)
    }

    func test_whenFinishes_thenStartsMonitoring() {
        fc.transactionID = "some"
        fc.reviewTransactionViewControllerDidFinishReview(ReviewTransactionViewController())
        XCTAssertTrue(mockApplicationService.didStartMonitoring)
    }

    func test_tracking() {
        let mockWalletService = MockWalletApplicationService()
        ApplicationServiceRegistry.put(service: mockWalletService, for: WalletApplicationService.self)
        mockWalletService.transactionData_output = TransactionData.tokenData(status: .readyToSubmit)

        fc.transactionID = "tx"

        let introEvent = fc.introViewController().screenTrackingEvent as? ReplaceTwoFATrackingEvent
        XCTAssertEqual(introEvent, .intro)

        let scanEvent = fc.connectAuthenticatorViewController().screenTrackingEvent as? ReplaceTwoFATrackingEvent
        XCTAssertEqual(scanEvent, .scan)

        let phraseInputEvent = fc.phraseInputViewController().screenTrackingEvent
            as? ReplaceTwoFATrackingEvent
        XCTAssertEqual(phraseInputEvent, .enterSeed)

        let reviewEvent = fc.reviewViewController().screenTrackingEvent as? ReplaceTwoFATrackingEvent
        XCTAssertEqual(reviewEvent, .review)

        let successEvent = fc.reviewViewController().successTrackingEvent as? ReplaceTwoFATrackingEvent
        XCTAssertEqual(successEvent, .success)
    }

}

class MockReplaceExtensionApplicationService: ReplaceTwoFAApplicationService {

    var shouldThrow = false
    func throwIfNeeded() throws {
        enum MyError: Error { case error }
        if shouldThrow {
            throw MyError.error
        }
    }

    var didCallConnect = false
    override func connect(transaction: RBETransactionID, code: String) throws {
        didCallConnect = true
    }

    var didCallSignTransaction = false
    override func sign(transaction: RBETransactionID, withPhrase phrase: String) throws {
        try throwIfNeeded()
        didCallSignTransaction = true
    }

    var didStartMonitoring = false
    override func startMonitoring(transaction: RBETransactionID) {
        didStartMonitoring = true
    }

    override var isAvailable: Bool {
        return true
    }

}

class TestableReplaceTwoFAFlowCoordinator: ReplaceTwoFAFlowCoordinator {

    override func push(_ controller: UIViewController, onPop action: (() -> Void)?) {
        navigationController.pushViewController(controller, animated: false)
    }

}

class MockRecoveryPhraseInputViewController: RecoveryPhraseInputViewController {

    var didHandleError = false
    override func handleError(_ error: Error) {
        didHandleError = true
    }

    var didHandleSuccess = false
    override func handleSuccess() {
        didHandleSuccess = true
    }

}
