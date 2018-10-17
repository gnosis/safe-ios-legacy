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
        transaction.change(status: .draft)
        transaction.change(status: .signing)
        transaction.change(status: .discarded)
        transaction.change(status: .draft)
        transaction.change(status: .discarded)
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
        transaction.change(status: .pending)
        transaction.change(status: .discarded)
    }

    func test_timestampingAllowedInAnyButDiscardedState() {
        givenNewlyCreatedTransaction()
        let date1 = Date()
        let date2 = date1.addingTimeInterval(5)
        transaction.timestampSubmitted(at: date1)
            .timestampProcessed(at: date2)
        XCTAssertEqual(transaction.submittedDate, date1)
        XCTAssertEqual(transaction.processedDate, date2)
    }

    func test_whenGoesFromDiscardedBackToDraft_thenResetsData() {
        givenSigningTransaction()
        transaction.set(hash: .test1)
            .add(signature: signature)
            .change(status: .pending)
            .timestampSubmitted(at: Date())
            .change(status: .success)
            .timestampProcessed(at: Date())
            .change(status: .discarded)
        transaction.change(status: .draft)
        XCTAssertNil(transaction.transactionHash)
        XCTAssertNil(transaction.submittedDate)
        XCTAssertNil(transaction.processedDate)
        XCTAssertTrue(transaction.signatures.isEmpty)
    }

}

extension TransactionTests {

    private func givenNewlyCreatedTransaction() {
        let walletID = WalletID()
        transaction = Transaction(id: TransactionID(),
                                  type: .transfer,
                                  walletID: walletID,
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
            .change(status: .signing)
    }

}
