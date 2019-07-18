//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import CommonTestSupport
import MultisigWalletApplication
import SafariServices
import Common

class MainFlowCoordinatorTests: SafeTestCase {

    var mainFlowCoordinator: MainFlowCoordinator!

    override func setUp() {
        super.setUp()
        try! authenticationService.registerUser(password: "password")
        walletService.createReadyToUseWallet()
        mainFlowCoordinator = MainFlowCoordinator()
        mainFlowCoordinator.setUp()
    }

    func test_whenSetupCalled_thenShowsMainScreen() {
        XCTAssertTrue(mainFlowCoordinator.navigationController.topViewController is MainViewController)
    }

    func test_whenRegistering_thenAuthWithPushTokenCalled() {
        mainFlowCoordinator.registerForRemoteNotifciations()
        XCTAssertNotNil(walletService.authCalled)
    }

    func test_whenCreatingNewTransaction_thenOpensFundsTransferVC() {
        mainFlowCoordinator.createNewTransaction(token: ethID.id)
        delay()
        XCTAssertTrue(mainFlowCoordinator.navigationController.topViewController is SendInputViewController)
    }

    func test_whenOpenMenuRequested_thenOpensIt() {
        mainFlowCoordinator.openMenu()
        delay()
        XCTAssertTrue(mainFlowCoordinator.navigationController.topViewController
            is MenuTableViewController)
    }

    func test_whenDraftTransactionCreated_thenOpensTransactionReviewVC() {
        let data = createTransaction()
        let fc = SendFlowCoordinator(rootViewController: UINavigationController())
        fc.didCreateDraftTransaction(id: data.id)
        delay()
        let vc = fc.navigationController.topViewController as? ReviewTransactionViewController
        XCTAssertNotNil(vc)
        XCTAssertEqual(vc?.tx.id, "some")
    }

    func test_whenReceivingRemoteMessageData_thenPassesItToService() {
        mainFlowCoordinator.receive(message: ["key": "value"])
        delay()
        XCTAssertEqual(walletService.receive_input?["key"] as? String, "value")
    }

    // TODO: enable or refactor so it is not fragile
    func disabled_test_whenReceivingRemoteMessageAndReviewScreenNotOpened_thenOpensIt() {
        let data = createTransaction()
        mainFlowCoordinator.incomingTransactionFlowCoordinator.transactionID = data.id
        mainFlowCoordinator.receive(message: ["key": "value"])
        delay(0.7)
        let vc = mainFlowCoordinator.navigationController.topViewController
            as? ReviewTransactionViewController
        XCTAssertNotNil(vc)
        XCTAssertEqual(vc?.tx.id, data.id)
        XCTAssertTrue(vc?.delegate === mainFlowCoordinator.incomingTransactionFlowCoordinator)
    }

    func test_whenAlreadyOpenedReviewTransaction_thenJustUpdatesIt() {
        let data = createTransaction()
        mainFlowCoordinator.receive(message: ["key": "value"])
        delay(0.5)
        mainFlowCoordinator.receive(message: ["key": "value"])
        delay(0.5)
        XCTAssertEqual((mainFlowCoordinator.navigationController.topViewController
            as? ReviewTransactionViewController)?.tx.id, data.id)
    }

    func test_whenReviewTransactionFinished_thenPopsBack() {
        delay()
        let mainFC = mainFlowCoordinator!
        let sendFC = mainFC.sendFlowCoordinator
        let data = createTransaction()
        let vc = mainFC.navigationController.topViewController
        mainFC.createNewTransaction(token: data.amountTokenData.address)
        delay()
        mainFC.sendFlowCoordinator.didCreateDraftTransaction(id: data.id)
        delay()
        let reviewVC = sendFC.navigationController.topViewController as! ReviewTransactionViewController
        sendFC.reviewTransactionViewControllerDidFinishReview(reviewVC)
        delay()
        XCTAssertTrue(mainFC.navigationController.topViewController is SuccessViewController)
        let successVC = mainFC.navigationController.topViewController as! SuccessViewController
        successVC.action()
        delay()
        XCTAssertTrue(vc === mainFC.navigationController.topViewController)
    }

    func test_whenUserIsAuthenticated_thenTransactionCanSubmit() throws {
        try authenticationService.registerUser(password: "pass")
        authenticationService.allowAuthentication()
        _ = try authenticationService.authenticateUser(.password("pass"))
        let exp = expectation(description: "submit")
        TransactionSubmissionHandler().submitTransaction(from: mainFlowCoordinator) { success in
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
        TransactionSubmissionHandler().submitTransaction(from: mainFlowCoordinator) { success in
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
            is ReceiveFundsViewController)
    }

    func test_whenSelectingTransaction_thenPushesTransactionDetailController() {
        walletService.transactionData_output = TransactionData.pending
        mainFlowCoordinator.didSelectTransaction(id: "some")
        delay()
        XCTAssertTrue(mainFlowCoordinator.navigationController.topViewController
            is TransactionDetailsViewController)
    }

    func test_whenShowsInExternalApp_thenOpensSafariController() {
        createWindow(mainFlowCoordinator.rootViewController)
        let controller = TransactionDetailsViewController.create(transactionID: "some")
        mainFlowCoordinator.showTransactionInExternalApp(from: controller)
        delay()
        XCTAssertTrue(mainFlowCoordinator.navigationController.presentedViewController
            is SFSafariViewController)
    }

    // MARK: - MenuTableViewControllerDelegate

    func test_didSelectManageTokens_entersManageTokensFlow() {
        createWindow(mainFlowCoordinator.rootViewController)
        mainFlowCoordinator.didSelectCommand(ManageTokensCommand())
        delay()
        let presented = mainFlowCoordinator.navigationController.presentedViewController
        XCTAssertTrue(presented?.children[0] is ManageTokensTableViewController)
    }

    func test_whenSelectingTermsOfUse_thenOpensSafari() {
        var config = WalletApplicationServiceConfiguration.default
        config.termsOfUseURL = URL(string: "https://gnosis.pm/")!
        reconfigureService(with: config)
        createWindow(mainFlowCoordinator.rootViewController)
        mainFlowCoordinator.didSelectCommand(TermsCommand())
        delay()
        XCTAssertTrue(mainFlowCoordinator.navigationController.presentedViewController
            is SFSafariViewController)
    }

    func test_whenSelectingPrivacyPolicy_thenOpensSafari() {
        var config = WalletApplicationServiceConfiguration.default
        config.privacyPolicyURL = URL(string: "https://gnosis.pm/")!
        reconfigureService(with: config)
        createWindow(mainFlowCoordinator.rootViewController)
        mainFlowCoordinator.didSelectCommand(PrivacyPolicyCommand())
        delay()
        XCTAssertTrue(mainFlowCoordinator.navigationController.presentedViewController
            is SFSafariViewController)
    }

    @discardableResult
    private func createTransaction() -> TransactionData {
        let data = TransactionData.ethData(status: .waitingForConfirmation)
        walletService.receive_output = data.id
        walletService.transactionData_output = TransactionData.ethData(status: .waitingForConfirmation)
        return data
    }

    func test_tracking() {
        let fc = ReplaceRecoveryPhraseFlowCoordinator(rootViewController: UINavigationController())
        let vc = fc.saveMnemonicViewController()
        vc.recoveryModeEnabled = true
        ethereumService.prepareToGenerateExternallyOwnedAccount(address: "some", mnemonic: ["one", "two"])
        vc.loadViewIfNeeded()

        let enterPhraseEvent = vc.screenTrackingEvent as? ReplaceRecoveryPhraseTrackingEvent
        XCTAssertEqual(enterPhraseEvent, .showSeed)

        let confirmPhraseEvent = fc.confirmMnemonicViewController(vc).screenTrackingEvent
            as? ReplaceRecoveryPhraseTrackingEvent
        XCTAssertEqual(confirmPhraseEvent, .enterSeed)
    }

    func test_whenReceivesURL_thenEntersWalletConnectFlow() {
        mainFlowCoordinator.receive(url: URL(string: "wc:123")!)
        XCTAssertNotNil(mainFlowCoordinator.walletConnectFlowCoordinator)
    }

}
