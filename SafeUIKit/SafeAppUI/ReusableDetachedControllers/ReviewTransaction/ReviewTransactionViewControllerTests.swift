//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import MultisigWalletApplication
import BigInt
import Common
import SafeUIKit
import CommonTestSupport

class ReviewTransactionViewControllerTests: XCTestCase {

    let service = MockWalletApplicationService()
    // swiftlint:disable:next weak_delegate
    let delegate = MockReviewTransactionViewControllerDelegate()

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: service, for: WalletApplicationService.self)
        ApplicationServiceRegistry.put(service: MockLogger(), for: Logger.self)
    }

    // MARK: - Layout

    func test_whenLoaded_thenSetsTransactionHeaderAccordingToTransactionData() {
        let (data, vc) = ethDataAndCotroller()
        let headerCell = vc.cellForRow(0) as! TransactionHeaderCell
        XCTAssertEqual(headerCell.transactionHeaderView.assetCode, data.amountTokenData.code)
        XCTAssertEqual(headerCell.transactionHeaderView.assetInfo,
                       LocalizedString("transaction.outgoing_transfer", comment: ""))
    }

    func test_whenLoaded_thenSetsTransferViewAccordingToTransactionData() {
        let (data, vc) = ethDataAndCotroller()
        let transferViewCell = vc.cellForRow(1) as! TransferViewCell
        XCTAssertEqual(transferViewCell.transferView.fromAddress, data.sender)
        XCTAssertEqual(transferViewCell.transferView.toAddress, data.recipient)
        XCTAssertEqual(transferViewCell.transferView.tokenData, data.amountTokenData)
    }

    func test_whenLoadedForEtherTransfer_theneTransactionFeeCellHasCorrectValues() {
        let (data, vc) = ethDataAndCotroller()
        XCTAssertEqual(vc.cellCount(), 4)

        let cell = vc.cellForRow(2) as! TransactionFeeCell
        let balance = service.accountBalance(tokenID: BaseID(data.amountTokenData.address))!

        XCTAssertEqual(cell.transactionFeeView.currentBalance?.balance,
                       balance)
        XCTAssertEqual(cell.transactionFeeView.transactionFee?.balance,
                       data.feeTokenData.balance!)
        XCTAssertEqual(cell.transactionFeeView.resultingBalance?.balance,
                       balance - data.feeTokenData.balance! - data.amountTokenData.balance!)
    }

    func test_whenLoadedForTokenTransfer_thenHasTwoTransactionFeeCellsWithCorrectValues() {
        let (data, vc) = tokenDataAndCotroller()
        XCTAssertEqual(vc.cellCount(), 5)

        let cellOne = vc.cellForRow(2) as! TransactionFeeCell
        let tokenBalance = service.accountBalance(tokenID: BaseID(data.amountTokenData.address))!

        XCTAssertEqual(cellOne.transactionFeeView.currentBalance?.balance,
                       tokenBalance)
        XCTAssertNil(cellOne.transactionFeeView.transactionFee?.balance)
        XCTAssertEqual(cellOne.transactionFeeView.resultingBalance?.balance,
                       tokenBalance - data.amountTokenData.balance!)

        let cellTwo = vc.cellForRow(3) as! TransactionFeeCell
        let feeBalance = service.accountBalance(tokenID: BaseID(data.feeTokenData.address))!

        XCTAssertNil(cellTwo.transactionFeeView.currentBalance?.balance)
        XCTAssertEqual(cellTwo.transactionFeeView.transactionFee?.balance,
                       data.feeTokenData.balance!)
        XCTAssertEqual(cellTwo.transactionFeeView.resultingBalance?.balance,
                       feeBalance - data.feeTokenData.balance!)
    }

    func test_whenBrowserExtensionIsNotPaired_thenHidesTransactionReviewCell() {
        let (_, vc) = ethDataAndCotroller()
        XCTAssertTrue(vc.cellForRow(3) is TransactionConfirmationCell)
        XCTAssertEqual(vc.cellHeight(3), 0)
    }

    func test_whenBrowserExtensionIsPaired_thenShowsTransactionReviewCell() {
        let (_, vc) = ethDataAndCotroller()
        service.addOwner(address: "test", type: .browserExtension)
        XCTAssertTrue(vc.cellForRow(3) is TransactionConfirmationCell)
        XCTAssertNotEqual(vc.cellHeight(3), 0)
    }

    // MARK: - Transaction Review Cell states

    func test_whenTransactionIsWaitingForConfirmation_thenConfirmationCellIsPending() {
        let (_, vc) = ethDataAndCotroller(.waitingForConfirmation)
        vc.viewDidAppear(false)
        delay()
        XCTAssertEqual(vc.confirmationCell.transactionConfirmationView.status, .pending)
    }

    func test_whenTransactionIsReadyToSubmit_thenConfirmationCellIsConfirmed() {
        let (_, vc) = ethDataAndCotroller(.readyToSubmit)
        vc.viewDidAppear(false)
        delay()
        XCTAssertEqual(vc.confirmationCell.transactionConfirmationView.status, .confirmed)
    }

    func test_whenTransactionIsRejected_thenConfirmationCellIsRejected() {
        let (_, vc) = ethDataAndCotroller(.rejected)
        vc.viewDidAppear(false)
        delay()
        XCTAssertEqual(vc.confirmationCell.transactionConfirmationView.status, .rejected)
    }

    func test_whenTransactionIsOther_thenConfirmationCellIsUndefined() {
        let (_, vc) = ethDataAndCotroller(.pending)
        vc.viewDidAppear(false)
        XCTAssertEqual(vc.confirmationCell.transactionConfirmationView.status, .undefined)
    }

    func test_whenUpdatingWithNewTransactionData_thenIgnoresIt() {
        let (_, vc) = ethDataAndCotroller(.waitingForConfirmation)
        XCTAssertEqual(vc.cellCount(), 4)
        let (newData, _) = tokenDataAndCotroller(.waitingForConfirmation)
        vc.update(with: newData)
        XCTAssertEqual(vc.cellCount(), 4)
    }

    // MARK: - Requesting signatures

    func test_whenAppeared_thenRequestsSignatures() {
        let (_, vc) = ethDataAndCotroller(.waitingForConfirmation)
        XCTAssertNil(service.requestTransactionConfirmation_input)
        vc.viewDidAppear(false)
        delay()
        XCTAssertNotNil(service.requestTransactionConfirmation_input)
        service.requestTransactionConfirmation_input = nil
    }

    func test_whenRequestingConfirmationsFails_thenAlertIsShown() {
        service.requestTransactionConfirmation_throws = true
        let (_, vc) = ethDataAndCotroller(.waitingForConfirmation)
        vc.viewDidAppear(false)
        delay()
        XCTAssertAlertShown(message: MockWalletApplicationService.Error.error.errorDescription)
    }

    // MARK: - Submitting

    func test_whenLoaded_thenSubmitButtonIsEnabled() {
        let (_, vc) = ethDataAndCotroller(.waitingForConfirmation)
        XCTAssertNotNil(vc.navigationItem.rightBarButtonItem)
        XCTAssertEqual(vc.navigationItem.rightBarButtonItem?.title, ReviewTransactionViewController.Strings.submit)
    }

    func test_whenSubmittingUnconfirmedTranasction_thenShowsAlert() {
        let (_, vc) = ethDataAndCotroller(.waitingForConfirmation)
        createWindow(vc)
        vc.submit()
        delay()
        XCTAssertAlertShown(message: ReviewTransactionViewController.Strings.Alert.description, actionCount: 2)
    }

    func test_whenSubmittingConfirmedTransaction_thenCallsDelegate() {
        let (_, vc) = ethDataAndCotroller(.readyToSubmit)
        vc.submit()
        XCTAssertTrue(delegate.requestedToSubmit)
    }

    // TODO: test_whenSubmittingConfirmedTransactonAndNotAllowed_thenDoesNothing
    // TODO: test_whenSubmittingConfirmedTransactonAndAllowed_thenCallesDelegateOnSuccess

}

private extension ReviewTransactionViewControllerTests {

    @discardableResult
    func ethDataAndCotroller(_ status: TransactionData.Status = .readyToSubmit) ->
        (TransactionData, ReviewTransactionViewController) {
        let data = TransactionData.ethData(status: status)
        let vc = controller(for: data)
        return (data, vc)
    }

    func tokenDataAndCotroller(_ status: TransactionData.Status = .readyToSubmit) ->
        (TransactionData, ReviewTransactionViewController) {
        let data = TransactionData.tokenData(status: status)
        let vc = controller(for: data)
        return (data, vc)
    }

    func controller(for data: TransactionData) -> ReviewTransactionViewController {
        service.transactionData_output = data
        service.requestTransactionConfirmation_output = data
        service.update(account: BaseID(data.amountTokenData.address), newBalance: BigInt(10).power(19))
        let vc = ReviewTransactionViewController(transactionID: data.id, delegate: delegate)
        vc.viewDidLoad()
        return vc
    }

}

private extension ReviewTransactionViewController {

    func cellForRow(_ row: Int) -> UITableViewCell {
        return tableView(tableView, cellForRowAt: IndexPath(row: row, section: 0))
    }

    func cellHeight(_ row: Int) -> CGFloat {
        return tableView(tableView, heightForRowAt: IndexPath(row: row, section: 0))
    }

    func cellCount() -> Int {
        return tableView(tableView, numberOfRowsInSection: 0)
    }

}

extension TransactionData {

    static func ethData(status: Status) -> TransactionData {
        return TransactionData(id: "some",
                               sender: "some",
                               recipient: "some",
                               amountTokenData: TokenData.Ether.withBalance(BigInt(10).power(18)),
                               feeTokenData: TokenData.Ether.withBalance(BigInt(10).power(17)),
                               status: status,
                               type: .outgoing,
                               created: nil,
                               updated: nil,
                               submitted: nil,
                               rejected: nil,
                               processed: nil)
    }

    static func tokenData(status: Status) -> TransactionData {
        return TransactionData(id: "some",
                               sender: "some",
                               recipient: "some",
                               amountTokenData: TokenData.gno.withBalance(BigInt(10).power(18)),
                               feeTokenData: TokenData.gno.withBalance(BigInt(10).power(17)),
                               status: status,
                               type: .outgoing,
                               created: nil,
                               updated: nil,
                               submitted: nil,
                               rejected: nil,
                               processed: nil)
    }

}

class MockReviewTransactionViewControllerDelegate: ReviewTransactionViewControllerDelegate {

    var requestedToSubmit = false
    var shouldAllowToSubmit = true
    func wantsToSubmitTransaction(_ completion: @escaping (_ allowed: Bool) -> Void) {
        requestedToSubmit = true
        completion(shouldAllowToSubmit)
    }

    var finished = false
    func didFinish() {
        finished = true
    }

}
