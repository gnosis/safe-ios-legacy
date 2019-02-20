//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import ReplaceBrowserExtensionUI
import MultisigWalletApplication
import ReplaceBrowserExtensionFacade

class ReplaceBrowserExtensionFlowCoordinatorTests: XCTestCase {

    let nav = UINavigationController()
    var fc: ReplaceBrowserExtensionFlowCoordinator!
    let mockSettingsService = MockWalletSettingsApplicationService()

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: mockSettingsService,
                                       for: WalletSettingsApplicationService.self)
        fc = TestableReplaceBrowserExtensionFlowCoordinator(rootViewController: nav)
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
        let vc = PairWithBrowserExtensionViewController.create(delegate: nil)
        try fc.pairWithBrowserExtensionViewController(vc, didScanAddress: "Address", code: "Code")
        XCTAssertTrue(mockSettingsService.didCallConnect)
    }

    func test_whenPairingFinishes_thenPresentsRecoveryPhraseInput() {
        fc.pairWithBrowserExtensionViewControllerDidFinish()
        XCTAssertTrue(nav.topViewController is RecoveryPhraseInputViewController)
    }

    func test_whenPhraseEntered_thenSignsTransaction() {
        let vc = RecoveryPhraseInputViewController.create(delegate: fc)
        fc.transactionID = "tx"
        fc.recoveryPhraseInputViewController(vc, didEnterPhrase: "phrase")
        XCTAssertTrue(mockSettingsService.didCallSignTransaction)
    }

    func test_whenSigningThrows_thenHandlesError() {
        let vc = MockRecoveryPhraseInputViewController()
        mockSettingsService.shouldThrow = true
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

}

class MockWalletSettingsApplicationService: WalletSettingsApplicationService {

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

}

class TestableReplaceBrowserExtensionFlowCoordinator: ReplaceBrowserExtensionFlowCoordinator {

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
