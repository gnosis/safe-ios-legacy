//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import SafeUIKit
import Common
import MultisigWalletApplication

class RBEIntroViewControllerLoadingStateTests: RBEIntroViewControllerBaseTestCase {

    let transactionID = "TestTransactionID"

    override func setUp() {
        // not loading view
    }

    func test_whenLoading_thenHasContent() {
        vc.enableStart()
        vc.loadViewIfNeeded()
        XCTAssertTrue(vc.navigationItem.titleView is LoadingTitleView)
        XCTAssertEqual(vc.navigationItem.rightBarButtonItems, [vc.startButtonItem])
        XCTAssertFalse(vc.startButtonItem.isEnabled)
    }

    func test_whenLoadingAndPushed_thenBackButtonIsSet() {
        let navVC = UINavigationController(rootViewController: UIViewController())
        navVC.pushViewController(vc, animated: false)
        vc.loadViewIfNeeded()
        vc.willMove(toParent: navVC)
        XCTAssertEqual(navVC.viewControllers.first!.navigationItem.backBarButtonItem, vc.backButtonItem)
    }

    func test_whenMovingToRootVC_thenOK() {
        let navVC = UINavigationController()
        navVC.setViewControllers([vc], animated: false)
        XCTAssertNil(vc.navigationItem.backBarButtonItem)
    }

    func test_whenMovingToNonNavigationParent_thenOK() {
        let parent = UIViewController()
        parent.addChild(vc)
        XCTAssertNil(vc.navigationItem.backBarButtonItem)
        XCTAssertNil(parent.navigationItem.backBarButtonItem)
    }

    func test_whenLoading_thenHasEmptyCalculation() {
        vc.loadViewIfNeeded()
        XCTAssertEqual(vc.feeCalculationView.calculation, EthFeeCalculation())
    }

    func test_whenNotCreatedTransaction_thenCreatesItAndEstimatesIt() {
        let mock = RBEStarterMock()
        mock.expect_create(returns: transactionID)
        mock.expect_estimate(transaction: transactionID, returns: .zero)
        vc.transactionID = nil
        vc.starter = mock

        transitionToLoading()

        mock.verify()
        XCTAssertEqual(vc.transactionID, transactionID)
    }

    func test_whenCreatedTransaction_thenReestimatesIt() {
        let mock = RBEStarterMock()
        mock.expect_estimate(transaction: transactionID, returns: .zero)
        vc.transactionID = transactionID
        vc.starter = mock

        transitionToLoading()

        mock.verify()
    }

    func test_whenEstimationInvalid_thenErrors() {
        let mock = RBEStarterMock()
        var estimateWithError = RBEEstimationResult.zero
        estimateWithError.error = FeeCalculationError.insufficientBalance
        mock.expect_estimate(transaction: transactionID, returns: estimateWithError)
        let vc = TestableRBEIntroViewController.createTestable()
        vc.transactionID = transactionID
        vc.starter = mock

        transitionToLoading(vc)

        XCTAssertEqual(vc.calculationData, estimateWithError.feeCalculation)
        XCTAssertTrue(vc.spy_handleError_invoked)
    }

    func test_whenEstimated_thenSavesEstimationAndCallsDidLoad() {
        let mock = RBEStarterMock()
        let estimation = RBEEstimationResult.zero
        mock.expect_estimate(transaction: transactionID, returns: estimation)
        let vc = TestableRBEIntroViewController.createTestable()
        vc.transactionID = transactionID
        vc.starter = mock

        transitionToLoading(vc)

        XCTAssertEqual(vc.calculationData, estimation.feeCalculation)
        XCTAssertTrue(vc.spy_didLoad_invoked)
    }

}

extension RBEIntroViewControllerLoadingStateTests {

    func transitionToLoading(_ vc: RBEIntroViewController? = nil) {
        let state = RBEIntroViewController.LoadingState()
        let exp = expectation(description: "Loading")
        state.addCompletion { exp.fulfill() }
        (vc ?? self.vc).state = state
        (vc ?? self.vc).loadViewIfNeeded()
        waitForExpectations(timeout: 0.1, handler: nil)
    }

}

extension TokenData {
    static let zero = TokenData.Ether.withBalance(0)
}

extension RBEFeeCalculationData {
    static let zero = RBEFeeCalculationData(currentBalance: .zero, networkFee: .zero, balance: .zero)
}

extension RBEEstimationResult {
    static let zero = RBEEstimationResult(feeCalculation: .zero, error: nil)
}
