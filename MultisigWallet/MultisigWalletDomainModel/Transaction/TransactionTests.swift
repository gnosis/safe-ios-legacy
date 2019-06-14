//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel

class TransactionTests: XCTestCase {

    var transaction: Transaction!
    let signature = Signature(data: Data(), address: .testAccount1)

    func test_whenNew_thenIsDraft() {
        givenNewlyCreatedTransaction()
        XCTAssertEqual(transaction.status, .draft)
    }

    func test_whenChangesAmount_thenCanQueryIt() {
        givenNewlyCreatedTransaction()
        transaction.change(amount: .ether(1))
        XCTAssertEqual(transaction.amount, TokenAmount.ether(1))
    }

    func test_whenChangingTransactionData_thenCanQueryIt() {
        givenNewlyCreatedTransaction()
        transaction.change(fee: .ether(1))
        XCTAssertEqual(transaction.fee, TokenAmount.ether(1))
        transaction.change(sender: .testAccount2)
        XCTAssertEqual(transaction.sender, Address.testAccount2)
        transaction.change(recipient: .testAccount3)
        XCTAssertEqual(transaction.recipient, Address.testAccount3)
    }

    func test_statusChangesFromDraftStatus() {
        givenNewlyCreatedTransaction()
        moveToSigningStatus()
        transaction.discard()
        transaction.reset()
        transaction.discard()
    }

    func test_whenInDraft_thenCanAddSignature() {
        givenNewlyCreatedTransaction()
        transaction.add(signature: signature)
        XCTAssertEqual(transaction.signatures, [signature])
    }

    func test_whenAddingSignatureTwice_thenIgnoresDuplicate() {
        givenNewlyCreatedTransaction()
        transaction.add(signature: signature)
        transaction.add(signature: signature)
        XCTAssertEqual(transaction.signatures, [signature])
    }

    func test_whenInSigning_thenCanAddSignature() {
        givenSigningTransaction()
        transaction.add(signature: signature)
    }

    func test_whenAddedSignature_thenCanRemoveIt() {
        givenNewlyCreatedTransaction()
        transaction.add(signature: signature)
        transaction.remove(signature: signature)
        XCTAssertTrue(transaction.signatures.isEmpty)
    }

    func test_whenInDraftOrSigningOrPending_thenCanChangeHash() {
        givenNewlyCreatedTransaction()
        transaction.set(hash: .test1)
        XCTAssertEqual(transaction.transactionHash,
                       TransactionHash.test1)
        moveToSigningStatus()
        transaction.set(hash: .test2)
        transaction.proceed()
        transaction.discard()
    }

    func test_timestampingAllowedInAnyButDiscardedState() {
        givenNewlyCreatedTransaction()
        let dates = (0..<5).map { Date(timeIntervalSinceNow: TimeInterval($0 * 5)) }
        transaction
            .timestampCreated(at: dates[0])
            .timestampUpdated(at: dates[1])
            .timestampRejected(at: dates[2])
            .timestampSubmitted(at: dates[3])
            .timestampProcessed(at: dates[4])
        let actual = [transaction.createdDate, transaction.updatedDate, transaction.rejectedDate,
                      transaction.submittedDate, transaction.processedDate].compactMap { $0 }
        XCTAssertEqual(actual, dates)
    }

    func test_whenGoesFromDiscardedBackToDraft_thenResetsData() {
        givenSigningTransaction()
        transaction
            .timestampCreated(at: Date())
            .set(hash: .test1)
            .timestampUpdated(at: Date())
            .add(signature: signature)
            .proceed()
            .timestampSubmitted(at: Date())
            .succeed()
            .timestampProcessed(at: Date())
            .timestampRejected(at: Date())
            .discard()
        transaction.reset()
        XCTAssertNil(transaction.transactionHash)
        XCTAssertNil(transaction.submittedDate)
        XCTAssertNil(transaction.processedDate)
        XCTAssertNil(transaction.createdDate)
        XCTAssertNil(transaction.updatedDate)
        XCTAssertNil(transaction.rejectedDate)
        XCTAssertTrue(transaction.signatures.isEmpty)
    }

    func test_whenTokenAmountIsNonEth_thenEthToAndValueAreCorrect() {
        givenNewlyCreatedTransaction()
        transaction.change(amount: TokenAmount(amount: 10, token: .gno))
        XCTAssertEqual(transaction.ethTo, Token.gno.address)
        XCTAssertEqual(transaction.ethValue, 0)
        XCTAssertEqual(transaction.amount?.amount, 10)
    }

    func test_whenTokenAmountIsEth_thenEthToAndValueAreCorrect() {
        givenNewlyCreatedTransaction()
        transaction.change(recipient: Address.testAccount1)
        XCTAssertEqual(transaction.ethTo, transaction.recipient)
        transaction.change(amount: TokenAmount(amount: 9, token: .Ether))
        XCTAssertEqual(transaction.ethValue, 9)
    }

    func test_whenAmountAndRecipientNotSet_thenEthToAndEthValueAreZero() {
        givenNewlyCreatedTransaction()
        transaction.change(amount: nil).change(recipient: nil)
        XCTAssertEqual(transaction.ethTo, .zero)
        XCTAssertEqual(transaction.ethValue, 0)
    }

    func test_ethData() {
        givenNewlyCreatedTransaction()
        transaction.change(data: nil)
        XCTAssertTrue(transaction.ethData.isEmpty)
        transaction.change(data: Data([7]))
        XCTAssertEqual(transaction.ethData, "0x07")
    }

}

extension TransactionTests {

    private func givenNewlyCreatedTransaction() {
        let walletID = WalletID()
        transaction = Transaction(id: TransactionID(),
                                  type: .transfer,
                                  accountID: AccountID(tokenID: Token.gno.id, walletID: walletID))
    }

    private func givenSigningTransaction() {
        givenNewlyCreatedTransaction()
        moveToSigningStatus()
    }

    private func moveToSigningStatus() {
        transaction.change(amount: .ether(0))
            .change(fee: .ether(0))
            .change(sender: .testAccount1)
            .change(recipient: .testAccount2)
            .proceed()
    }

}
