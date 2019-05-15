//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import MultisigWalletApplication

class ConnectBrowserExtensionFlowCoordinatorTests: XCTestCase {

    let nav = UINavigationController()
    var fc: TestableConnectBrowserExtensionFlowCoordinator!
    let mockApplicationService = MockConnectExtensionApplicationService()
    let mockWalletService = MockWalletApplicationService()

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: mockApplicationService,
                                       for: ConnectBrowserExtensionApplicationService.self)
        ApplicationServiceRegistry.put(service: mockWalletService, for: WalletApplicationService.self)
        fc = TestableConnectBrowserExtensionFlowCoordinator(rootViewController: nav)
        fc.setUp()
        fc.transactionID = "tx"
    }

    func test_onEnter_pushesIntro() {
        XCTAssertTrue(nav.topViewController is RBEIntroViewController)
        XCTAssertTrue(fc.intro.delegate === fc, "Delegate is not set")
    }

    func test_whenDidStart_thenOpensPairController() {
        fc.transactionID = nil
        fc.intro.transactionID = "tx"
        fc.rbeIntroViewControllerDidStart()
        XCTAssertTrue(nav.topViewController is PairWithBrowserExtensionViewController)
        XCTAssertEqual(fc.transactionID, "tx")
    }

    func test_whenDidScan_thenConnectsExtension() throws {
        try fc.pairWithBrowserExtensionViewController(PairWithBrowserExtensionViewController(),
                                                      didScanAddress: "address",
                                                      code: "code")
        XCTAssertTrue(mockApplicationService.didCallConnect)
    }

    func test_whenFinishesPairing_thenReviewOpens() {
        mockWalletService.transactionData_output = TransactionData.tokenData(status: .readyToSubmit)
        fc.pairWithBrowserExtensionViewControllerDidFinish()
        XCTAssertTrue(nav.topViewController is ReviewTransactionViewController)
    }

    func test_whenWantsToSubmit_thenUsesHandler() {
        let testableHandler = TestableTransactionSubmissionHandler()
        fc.transactionSubmissionHandler = testableHandler
        fc.reviewTransactionViewControllerWantsToSubmitTransaction(ReviewTransactionViewController()) { _ in }
        XCTAssertTrue(testableHandler.didSubmit)
    }

    func test_whenFinishesReview_thenStartsMonitoring() {
        fc.reviewTransactionViewControllerDidFinishReview(ReviewTransactionViewController())
        XCTAssertTrue(mockApplicationService.didStartMonitoring)
    }

    func test_whenFinishesReview_thenExitsFlo() {
        fc.reviewTransactionViewControllerDidFinishReview(ReviewTransactionViewController())
        XCTAssertTrue(fc.didExit)
    }

    func test_tracking() {
        mockWalletService.transactionData_output = TransactionData.tokenData(status: .readyToSubmit)

        let introEvent = fc.introViewController().screenTrackingEvent as? ConnectBrowserExtensionTrackingEvent
        XCTAssertEqual(introEvent, .intro)

        let reviewScreenEvent = fc.reviewViewController().screenTrackingEvent as? ConnectBrowserExtensionTrackingEvent
        XCTAssertEqual(reviewScreenEvent, .review)

        let successEvent = fc.reviewViewController().successTrackingEvent as? ConnectBrowserExtensionTrackingEvent
        XCTAssertEqual(successEvent, .success)
    }

}

class MockConnectExtensionApplicationService: ConnectBrowserExtensionApplicationService {

    var didStartMonitoring = false
    override func startMonitoring(transaction: RBETransactionID) {
        didStartMonitoring = true
    }

    var didCallConnect = false
    override func connect(transaction: RBETransactionID, code: String) throws {
        didCallConnect = true
    }

    var isAvailableResult: Bool = true
    override var isAvailable: Bool { return isAvailableResult }

    override func create() -> RBETransactionID {
        return "SomeID"
    }

    override func estimate(transaction: RBETransactionID) -> RBEEstimationResult {
        return RBEEstimationResult.zero
    }

    override func start(transaction: RBETransactionID) throws {}

}

class TestableTransactionSubmissionHandler: TransactionSubmissionHandler {

    var didSubmit = false

    override func submitTransaction(from flowCoordinator: FlowCoordinator, completion: @escaping (Bool) -> Void) {
        didSubmit = true
    }

}

class TestableConnectBrowserExtensionFlowCoordinator: ConnectBrowserExtensionFlowCoordinator {

    override func push(_ controller: UIViewController, onPop action: (() -> Void)?) {
        navigationController.pushViewController(controller, animated: false)
    }

    var didExit = false

    override func exitFlow() {
        didExit = true
    }

}
