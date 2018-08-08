//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import MultisigWalletApplication
import BigInt
import CommonTestSupport

class TransactionReviewViewControllerTests: XCTestCase {

    let service = MockWalletApplicationService()
    let vc = TransactionReviewViewController.create()
    // swiftlint:disable weak_delegate
    let delegate = MockTransactionReviewViewControllerDelegate()

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: service, for: WalletApplicationService.self)
    }

    func test_whenLoaded_thenTakesDataFromTransaction() {
        let sender = "0x8f51473aa98096145a9cadc421e4d33833e47365"
        let recipient = "0xFe2149773B3513703E79Ad23D05A778A185016ee"
        let amount = "0.1 ETH"
        let balance = "1 ETH"
        let id = "some"
        let fee = "-0.01 ETH"

        service.update(account: "ETH", newBalance: BigInt(10).power(18))

        service.transactionData_output = TransactionData(id: id,
                                                         sender: sender,
                                                         recipient: recipient,
                                                         amount: BigInt(10).power(17),
                                                         token: "ETH",
                                                         fee: BigInt(10).power(16),
                                                         status: .waitingForConfirmation)


        let vc = TransactionReviewViewController.create()
        vc.transactionID = id
        vc.loadViewIfNeeded()

        XCTAssertEqual(vc.senderView.address, sender)

        XCTAssertEqual(vc.recipientView.address, recipient)

        XCTAssertTrue(vc.transactionValueView.isSingleValue)
        XCTAssertEqual(vc.transactionValueView.tokenAmount, amount)

        XCTAssertEqual(vc.safeBalanceValueLabel.text, balance)
        XCTAssertEqual(vc.feeValueLabel.text, fee)
        XCTAssertTrue(vc.dataInfoStackView.isHidden)
    }

    func test_whenLoaded_thenLocksTransaction() {
        service.createReadyToUseWallet()
        vc.transactionID = "some"
        service.transactionData_output = TransactionData.create(status: .waitingForConfirmation)
        service.requestTransactionConfirmation_output = TransactionData.create(status: .waitingForConfirmation)

        vc.loadViewIfNeeded()
        delay()
        XCTAssertEqual(service.requestTransactionConfirmation_input, "some")
        XCTAssertEqual(vc.feeValueLabel.text, "-1 ETH")
    }

    func test_whenTransactionPending_thenCallsDelegate() {
        service.createReadyToUseWallet()
        vc.transactionID = "some"
        vc.delegate = delegate
        service.transactionData_output = TransactionData.create(status: .readyToSubmit)
        vc.loadViewIfNeeded()
        delay()
        service.submitTransaction_output = TransactionData.create(status: .pending)
        vc.actionButton.sendActions(for: .touchUpInside)
        delay()
        XCTAssertEqual(service.submitTransaction_input, "some")
        XCTAssertTrue(delegate.didCall)
    }

    func test_whenDelegateForbidsSubmission_thenDoesNotSubmit() {
        service.createReadyToUseWallet()
        vc.delegate = delegate
        vc.transactionID = "some"
        service.transactionData_output = TransactionData.create(status: .readyToSubmit)
        delegate.shouldSubmit = false
        vc.loadViewIfNeeded()
        vc.actionButton.sendActions(for: .touchUpInside)
        delay()
        XCTAssertNil(service.submitTransaction_input)
    }

    func test_whenNoDelegate_thenSubmitsRightAway() {
        service.createReadyToUseWallet()
        vc.transactionID = "some"
        service.transactionData_output = TransactionData.create(status: .readyToSubmit)
        vc.loadViewIfNeeded()
        vc.actionButton.sendActions(for: .touchUpInside)
        delay()
        XCTAssertNotNil(service.submitTransaction_input)
    }

}

extension TransactionData {

    static func create(status: Status) -> TransactionData {
        return TransactionData(id: "some",
                               sender: "some",
                               recipient: "some",
                               amount: 100,
                               token: "ETH",
                               fee: BigInt(10).power(18),
                               status: status)
    }

}

class MockTransactionReviewViewControllerDelegate: TransactionReviewViewControllerDelegate {

    var didCall = false
    var shouldSubmit = true

    func transactionReviewViewControllerDidFinish() {
        didCall = true
    }

    func transactionReviewViewControllerWantsToSubmitTransaction(completionHandler: @escaping (Bool) -> Void) {
        completionHandler(shouldSubmit)
    }

}
