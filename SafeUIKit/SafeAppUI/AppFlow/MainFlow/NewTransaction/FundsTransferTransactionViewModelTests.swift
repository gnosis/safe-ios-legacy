//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import MultisigWalletApplication
import BigInt
import CommonTestSupport
import Common

class TransactionViewModelTests: XCTestCase {

    let walletService = MockWalletApplicationService()
    let walletAddress = "0x1CBFf6551B8713296b0604705B1a3B76D238Ae14"
    let balance = BigInt(1_000)
    var model: FundsTransferTransactionViewModel!
    let ethID = BaseID("0x0000000000000000000000000000000000000000")

    override func setUp() {
        super.setUp()
        walletService.assignAddress(walletAddress)
        walletService.update(account: ethID, newBalance: balance)
        ApplicationServiceRegistry.put(service: walletService, for: WalletApplicationService.self)
        model = FundsTransferTransactionViewModel(senderName: "safe", tokenID: ethID) { /* empty */ }
        model.start()
    }

    func test_start() {
        XCTAssertEqual(model.senderName, "safe")
        XCTAssertEqual(model.senderAddress, walletAddress)
        XCTAssertEqual(model.balance, model.tokenFormatter.string(from: balance))
        XCTAssertEqual(model.amount, nil)
        XCTAssertEqual(model.recipient, nil)
        XCTAssertEqual(model.fee, "--")
        XCTAssertFalse(model.canProceedToSigning)
        XCTAssertTrue(model.amountErrors.isEmpty)
        XCTAssertTrue(model.recipientErrors.isEmpty)
    }

    func test_whenAmountChangedToInvalid_thenError() {
        model.change(amount: "")
        XCTAssertFalse(model.amountErrors.isEmpty)
    }

    func test_whenAmountErased_thenErrorsCleared() {
        model.change(amount: "")
        model.change(amount: nil)
        XCTAssertTrue(model.amountErrors.isEmpty)
    }

    func test_whenRecipientChangedToInvalid_thenError() {
        model.change(recipient: "")
        XCTAssertFalse(model.recipientErrors.isEmpty)
    }

    func test_whenRecipientErased_thenErrorsCleared() {
        model.change(recipient: "")
        model.change(recipient: nil)
        XCTAssertTrue(model.recipientErrors.isEmpty)
    }

    func test_whenWalletBalanceNil_thenBalanceIsNil() {
        walletService.update(account: ethID, newBalance: nil)
        model.start()
        XCTAssertNil(model.balance)
    }

    func test_whenAmountChangesToSameValue_nothingHappens() {
        var changed: Int = 0
        model = FundsTransferTransactionViewModel(senderName: "", tokenID: ethID) {
            changed += 1
        }
        model.start()
        model.change(amount: "a")
        let expected = changed
        model.change(amount: "a")
        XCTAssertEqual(changed, expected)
        XCTAssertGreaterThan(changed, 0)
    }

    func test_whenRecipientChangesToSameValue_nothingHappens() {
        var changed: Int = 0
        model = FundsTransferTransactionViewModel(senderName: "", tokenID: ethID) {
            changed += 1
        }
        model.start()
        model.change(recipient: "a")
        let expected = changed
        model.change(recipient: "a")
        XCTAssertEqual(changed, expected)
        XCTAssertGreaterThan(changed, 0)
    }

    func test_whenValidRecipient_thenEstimatesFees() {
        walletService.estimatedFee_output = 100
        model.change(recipient: walletAddress)
        delay()
        XCTAssertEqual(model.fee, model.tokenFormatter.string(from: -100))
    }

    func test_whenEnteredAllValidData_thenCanProceedToSigning() {
        walletService.estimatedFee_output = 100
        model.change(amount: "0.0000000000000000001")
        model.change(recipient: walletAddress)
        delay()
        XCTAssertTrue(model.canProceedToSigning)
    }

    func test_whenNotEnoughFunds_thenCanNotProceedToSigning() {
        walletService.estimatedFee_output = 100
        model.change(amount: "1")
        model.change(recipient: walletAddress)
        delay()
        XCTAssertFalse(model.canProceedToSigning)
    }

}
