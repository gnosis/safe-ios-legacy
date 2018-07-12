//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel

class TransactionTests: XCTestCase {

    var transaction: Transaction!
    let signature = Signature(data: Data(), address: BlockchainAddress(value: "signer"))

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
        transaction.change(sender: BlockchainAddress(value: "sender"))
        XCTAssertEqual(transaction.sender, BlockchainAddress(value: "sender"))
        transaction.change(recipient: BlockchainAddress(value: "recipient"))
        XCTAssertEqual(transaction.recipient, BlockchainAddress(value: "recipient"))
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
        XCTAssertNoThrow(transaction.set(hash: TransactionHash("hash1")))
        XCTAssertEqual(transaction.transactionHash, TransactionHash("hash1"))
        moveToSigningStatus()
        XCTAssertNoThrow(transaction.set(hash: TransactionHash("hash2")))
        transaction.change(status: .pending)
        transaction.change(status: .discarded)
    }

    func test_timestampingAllowedInAnyButDiscardedState() {
        givenNewlyCreatedTransaction()
        let date1 = Date()
        let date2 = date1.addingTimeInterval(5)
        XCTAssertNoThrow(transaction.timestampSubmitted(at: date1)
            .timestampProcessed(at: date2))
        XCTAssertEqual(transaction.submissionDate, date1)
        XCTAssertEqual(transaction.processedDate, date2)
    }

    func test_whenGoesFromDiscardedBackToDraft_thenResetsData() {
        givenSigningTransaction()
        transaction.set(hash: TransactionHash("hash"))
            .add(signature: signature)
            .change(status: .pending)
            .timestampSubmitted(at: Date())
            .change(status: .success)
            .timestampProcessed(at: Date())
            .change(status: .discarded)
        transaction.change(status: .draft)
        XCTAssertNil(transaction.transactionHash)
        XCTAssertNil(transaction.submissionDate)
        XCTAssertNil(transaction.processedDate)
        XCTAssertTrue(transaction.signatures.isEmpty)
    }

}

extension TransactionTests {

    private func givenNewlyCreatedTransaction() {
        transaction = Transaction(id: TransactionID(),
                                  type: .transfer,
                                  walletID: WalletID(),
                                  accountID: AccountID(token: "ETH"))
    }

    private func givenSigningTransaction() {
        givenNewlyCreatedTransaction()
        moveToSigningStatus()
    }

    private func moveToSigningStatus() {
        transaction.change(amount: .ether(0))
            .change(fee: .ether(0))
            .change(sender: BlockchainAddress(value: "sender"))
            .change(recipient: BlockchainAddress(value: "recipient"))
            .change(status: .signing)
    }

}
