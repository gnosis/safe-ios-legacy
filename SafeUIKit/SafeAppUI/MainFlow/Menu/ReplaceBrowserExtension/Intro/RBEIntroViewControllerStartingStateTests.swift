//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import SafeUIKit
import MultisigWalletApplication

class RBEIntroViewControllerStartingStateTests: RBEIntroViewControllerBaseTestCase {

    let transactionID: RBETransactionID = "StartTransactionID"
    let mock = RBEStarterMock()

    // swiftlint:disable:next overridden_super_call
    override func setUp() {
        // empty
    }

    func test_whenStarting_thenCorrectUI() {
        vc.stopIndicateLoading()
        vc.showRetry()
        vc.enableStart()

        vc.state = RBEIntroViewController.StartingState()
        vc.loadViewIfNeeded()
        vc.viewWillAppear(false)

        XCTAssertFalse(vc.startButtonItem.isEnabled)
        XCTAssertTrue(vc.navigationItem.titleView is LoadingTitleView)
        XCTAssertEqual(vc.navigationItem.rightBarButtonItems, [vc.startButtonItem])
    }

    func test_whenStarting_thenCallsStarter() {
        mock.expect_start(transaction: transactionID, throwing: nil)
        prepare()

        transitionToStarting()

        mock.verify()
    }

    func test_whenStartingFails_thenHandleError() {
        mock.expect_start(transaction: transactionID, throwing: MyError())
        let vc = TestableRBEIntroViewController.createTestable()
        prepare(vc)

        transitionToStarting(vc)

        XCTAssertTrue(vc.spy_handleError_invoked)
    }

    func test_whenStartingCompleted_thenCallsDidStart() {
        mock.expect_start(transaction: transactionID, throwing: nil)
        let vc = TestableRBEIntroViewController.createTestable()
        prepare(vc)

        transitionToStarting(vc)

        XCTAssertTrue(vc.spy_didStart_invoked)
    }

}

extension RBEIntroViewControllerStartingStateTests {

    func prepare(_ vc: RBEIntroViewController? = nil) {
        let controller = vc ?? self.vc
        controller.transactionID = transactionID
        controller.calculationData = .zero
        controller.starter = mock
    }

    func transitionToStarting(_ vc: RBEIntroViewController? = nil) {
        let state = RBEIntroViewController.StartingState()
        let exp = expectation(description: "Starting")
        state.addCompletion { exp.fulfill() }
        let controller = vc ?? self.vc
        controller.transition(to: state)
        waitForExpectations(timeout: 0.01, handler: nil)
    }

}
