//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import CommonTestSupport

class MainFlowCoordinatorTests: SafeTestCase {

    var mainFlowCoordinator: MainFlowCoordinator!

    override func setUp() {
        super.setUp()
        mainFlowCoordinator = MainFlowCoordinator(rootViewController: UINavigationController())
    }

    func test_whenSetupCalled_thenShowsMainScreen() {
        mainFlowCoordinator.setUp()
        XCTAssertTrue(mainFlowCoordinator.navigationController.topViewController is MainViewController)
    }

    func test_whenMainViewDidAppeatCalled_thenAuthWithPushTokenCalled() {
        mainFlowCoordinator.mainViewDidAppear()
        XCTAssertNotNil(walletService.authCalled)
    }

    func test_whenCreatingNewTransaction_thenOpensFundsTransferVC() {
        mainFlowCoordinator.setUp()
        mainFlowCoordinator.createNewTransaction()
        delay()
        XCTAssertTrue(mainFlowCoordinator.navigationController.topViewController
            is FundsTransferTransactionViewController)
    }

    func test_whenDraftTransactionCreated_thenOpensTransactionReviewVC() {
        mainFlowCoordinator.setUp()
        mainFlowCoordinator.didCreateDraftTransaction(id: "some")
        delay()
        let vc = mainFlowCoordinator.navigationController.topViewController as? TransactionReviewViewController
        XCTAssertNotNil(vc)
        XCTAssertEqual(vc?.transactionID, "some")
    }

}
