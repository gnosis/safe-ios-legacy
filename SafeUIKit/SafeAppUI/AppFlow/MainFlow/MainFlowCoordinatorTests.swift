//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import CommonTestSupport
import MultisigWalletApplication

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

    func test_whenReceivingRemoteMessageData_thenPassesItToService() {
        mainFlowCoordinator.receive(message: ["key": "value"])
        XCTAssertEqual(walletService.receive_input?["key"] as? String, "value")
    }

    func test_whenReceivingRemoteMessageAndReviewScreenNotOpened_thenOpensIt() {
        walletService.receive_output = "id"
        mainFlowCoordinator.setUp()
        mainFlowCoordinator.receive(message: ["key": "value"])
        delay()
        XCTAssertTrue(mainFlowCoordinator.navigationController.topViewController
            is TransactionReviewViewController)
        XCTAssertEqual((mainFlowCoordinator.navigationController.topViewController
            as? TransactionReviewViewController)?.transactionID, "id")
    }

    func test_whenAlreadyOpenedReviewTransaction_thenJustUpdatesIt() {
        walletService.receive_output = "id"
        walletService.transactionData_output = TransactionData(id: "some",
                                                               sender: "some",
                                                               recipient: "some",
                                                               amount: 100,
                                                               token: "ETH",
                                                               fee: 0)
        mainFlowCoordinator.setUp()
        mainFlowCoordinator.receive(message: ["key": "value"])
        delay()
        let controllerCount = mainFlowCoordinator.navigationController.viewControllers.count
        walletService.receive_output = "id2"
        mainFlowCoordinator.receive(message: ["key": "value"])
        delay()
        XCTAssertEqual((mainFlowCoordinator.navigationController.topViewController
            as? TransactionReviewViewController)?.transactionID, "id2")
        XCTAssertEqual(mainFlowCoordinator.navigationController.viewControllers.count, controllerCount)
    }

}
