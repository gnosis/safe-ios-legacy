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

class ReviewTransactionViewControllerTests: ReviewTransactionViewControllerBaseTestCase {

    let accountBalance = BigInt(10).power(19)

    // MARK: - Layout

    func test_whenBrowserExtensionIsNotPaired_thenHidesTransactionReviewCell() {
        let (_, vc) = ethDataAndCotroller()
        XCTAssertTrue(!vc.isShowing2FA)
    }

    func test_whenBrowserExtensionIsPaired_thenShowsTransactionReviewCell() {
        service.addOwner(address: "test", type: .browserExtension)
        let (_, vc) = ethDataAndCotroller()
        XCTAssertTrue(vc.isShowing2FA)
    }

    // MARK: - Transaction Review Cell states

    func test_whenTransactionIsWaitingForConfirmation_thenConfirmationCellIsPending() {
        let (_, vc) = ethDataAndCotroller(.waitingForConfirmation)
        vc.viewDidAppear(false)
        delay()
        XCTAssertEqual(vc.confirmationStatus, .pending)
    }

    func test_whenTransactionIsReadyToSubmit_thenConfirmationCellIsConfirmed() {
        let (_, vc) = ethDataAndCotroller(.readyToSubmit)
        vc.viewDidAppear(false)
        delay()
        XCTAssertEqual(vc.confirmationStatus, .confirmed)
    }

    func test_whenTransactionIsRejected_thenConfirmationCellIsRejected() {
        let (_, vc) = ethDataAndCotroller(.rejected)
        vc.viewDidAppear(false)
        delay()
        XCTAssertEqual(vc.confirmationStatus, .rejected)
    }

    func test_whenTransactionIsOther_thenConfirmationCellIsUndefined() {
        let (_, vc) = ethDataAndCotroller(.pending)
        vc.viewDidAppear(false)
        XCTAssertEqual(vc.confirmationStatus, .undefined)
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
        XCTAssertNotNil(vc.submitButton)
        XCTAssertTrue(vc.submitButton.isEnabled)
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
        delay()
        XCTAssertNotNil(service.submitTransaction_input)
    }

    func test_whenSubmittingConfirmedTransactonAndNotAllowed_thenDoesNothing() {
        let (_, vc) = ethDataAndCotroller(.readyToSubmit)
        delegate.shouldAllowToSubmit = false
        vc.submit()
        delay()
        XCTAssertNil(service.submitTransaction_input)
    }

    func test_whenSubmittingConfirmedTransactonAndAllowed_thenCallsDelegateOnSuccess() {
        let (_, vc) = ethDataAndCotroller(.readyToSubmit)
        service.submitTransaction_output = TransactionData.ethData(status: .success)
        vc.submit()
        delay()
        XCTAssertTrue(delegate.finished)
    }

}

extension ReviewTransactionViewControllerTests {

    @discardableResult
    func ethDataAndCotroller(_ status: TransactionData.Status = .readyToSubmit) ->
        (TransactionData, SendReviewViewController) {
        let data = TransactionData.ethData(status: status)
        let vc = controller(for: data)
        return (data, vc)
    }

    func tokenDataAndCotroller(_ status: TransactionData.Status = .readyToSubmit) ->
        (TransactionData, ReviewTransactionViewController) {
        let data = TransactionData.mixedTokenData(status: status)
        let vc = controller(for: data)
        return (data, vc)
    }

    func controller(for data: TransactionData) -> SendReviewViewController {
        service.transactionData_output = data
        service.requestTransactionConfirmation_output = data
        service.update(account: BaseID(data.amountTokenData.address), newBalance: accountBalance)
        let vc = SendReviewViewController(transactionID: data.id, delegate: delegate)
        vc.viewDidLoad()
        return vc
    }

}

extension ReviewTransactionViewController {

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

class MockReviewTransactionViewControllerDelegate: ReviewTransactionViewControllerDelegate {

    var requestedToSubmit = false
    var shouldAllowToSubmit = true

    func reviewTransactionViewControllerWantsToSubmitTransaction(_ controller: ReviewTransactionViewController,
                                                                 completion: @escaping (Bool) -> Void) {
        requestedToSubmit = true
        completion(shouldAllowToSubmit)
    }

    var finished = false

    func reviewTransactionViewControllerDidFinishReview(_ controller: ReviewTransactionViewController) {
        finished = true
    }

}
