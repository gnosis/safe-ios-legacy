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
        mainFlowCoordinator.setUp()
    }

    func test_whenSetupCalled_thenShowsMainScreen() {
        XCTAssertTrue(mainFlowCoordinator.navigationController.topViewController is MainViewController)
    }

    func test_whenMainViewDidAppeatCalled_thenAuthWithPushTokenCalled() {
        mainFlowCoordinator.mainViewDidAppear()
        XCTAssertNotNil(walletService.authCalled)
    }

    func test_whenCreatingNewTransaction_thenOpensFundsTransferVC() {
        mainFlowCoordinator.createNewTransaction()
        delay()
        XCTAssertTrue(mainFlowCoordinator.navigationController.topViewController
            is FundsTransferTransactionViewController)
    }

    func test_whenOpenMenuRequested_thenOpensIt() {
        mainFlowCoordinator.openMenu()
        delay()
        XCTAssertTrue(mainFlowCoordinator.navigationController.topViewController
            is MenuTableViewController)
    }

    func test_whenDraftTransactionCreated_thenOpensTransactionReviewVC() {
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
        mainFlowCoordinator.receive(message: ["key": "value"])
        delay()
        let vc = mainFlowCoordinator.navigationController.topViewController
            as? TransactionReviewViewController
        XCTAssertNotNil(vc)
        XCTAssertEqual(vc?.transactionID, "id")
        XCTAssertTrue(vc?.delegate === mainFlowCoordinator)
    }

    func test_whenAlreadyOpenedReviewTransaction_thenJustUpdatesIt() {
        walletService.receive_output = "id"
        walletService.transactionData_output = TransactionData(id: "some",
                                                               sender: "some",
                                                               recipient: "some",
                                                               amount: 100,
                                                               token: "ETH",
                                                               fee: 0,
                                                               status: .waitingForConfirmation)
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

    func test_whenReviewTransactionFinished_thenPopsBack() {
        delay()
        let vc = mainFlowCoordinator.navigationController.topViewController
        mainFlowCoordinator.createNewTransaction()
        delay()
        mainFlowCoordinator.transactionReviewViewControllerDidFinish()
        delay()
        XCTAssertTrue(vc === mainFlowCoordinator.navigationController.topViewController)
    }

    func test_whenUserIsAuthenticated_thenTransactionCanSubmit() throws {
        try authenticationService.registerUser(password: "pass")
        authenticationService.allowAuthentication()
        _ = try authenticationService.authenticateUser(.password("pass"))
        let exp = expectation(description: "submit")
        mainFlowCoordinator.transactionReviewViewControllerWantsToSubmitTransaction { success in
            XCTAssertTrue(success)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.5)
    }

    func test_whenUserNotAuthenticated_thenPresentsUnlockVC() throws {
        createWindow(mainFlowCoordinator.rootViewController)
        let exp = expectation(description: "submit")
        try authenticationService.registerUser(password: "111111A")
        authenticationService.allowAuthentication()
        mainFlowCoordinator.transactionReviewViewControllerWantsToSubmitTransaction { success in
            XCTAssertTrue(success)
            exp.fulfill()
        }
        delay()
        let vc = mainFlowCoordinator.navigationController.topViewController?.presentedViewController
            as! UnlockViewController
        vc.verifiableInput.text = "111111A"
        _ = vc.verifiableInput.textFieldShouldReturn(UITextField())
        authenticationService.blockAuthentication() // otherwise tries to auth on viewDidAppear
        waitForExpectations(timeout: 1)
    }

    func test_didSelectManageTokens_entersManageTokensFlow() {
        createWindow(mainFlowCoordinator.rootViewController)
        mainFlowCoordinator.didSelectManageTokens()
        delay()
        let presented = mainFlowCoordinator.navigationController.presentedViewController
        XCTAssertTrue(presented?.children[0] is ManageTokensTableViewController)
    }

    func test_whenManageTokensCalled_thenEntersManageTokensFlow() {
        createWindow(mainFlowCoordinator.rootViewController)
        mainFlowCoordinator.manageTokens()
        delay()
        let presented = mainFlowCoordinator.navigationController.presentedViewController
        XCTAssertTrue(presented?.children[0] is ManageTokensTableViewController)
    }

    func test_whenOpenAddressDetailsRequested_thenOpensIt() {
        mainFlowCoordinator.openAddressDetails()
        delay()
        XCTAssertTrue(mainFlowCoordinator.navigationController.topViewController
            is SafeAddressViewController)
    }

}
