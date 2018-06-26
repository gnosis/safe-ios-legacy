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

    func test_whenChangesAmount_thenCanQueryIt() throws {
        givenNewlyCreatedTransaction()
        try transaction.change(amount: .ether(1))
        XCTAssertEqual(transaction.amount, TokenAmount.ether(1))
    }

    func test_whenChangesAmountNotInDraftStatus_thenThrows() throws {
        try givenSigningTransaction()
        XCTAssertThrowsError(try transaction.change(amount: .ether(3)))
    }

    func test_whenChangingTransactionData_thenCanQueryIt() throws {
        givenNewlyCreatedTransaction()
        try transaction.change(fee: .ether(1))
        XCTAssertEqual(transaction.fee, TokenAmount.ether(1))
        try transaction.change(sender: BlockchainAddress(value: "sender"))
        XCTAssertEqual(transaction.sender, BlockchainAddress(value: "sender"))
        try transaction.change(recipient: BlockchainAddress(value: "recipient"))
        XCTAssertEqual(transaction.recipient, BlockchainAddress(value: "recipient"))
    }

    func test_whenTransitionsToSigningAndMissingData_thenThrowsError() {
        givenNewlyCreatedTransaction()
        XCTAssertThrowsError(try transaction.change(status: .signing))
    }

    func test_statusChangesFromDraftStatus() throws {
        givenNewlyCreatedTransaction()
        XCTAssertNoThrow(try moveToSigningStatus())
        XCTAssertNoThrow(try transaction.change(status: .draft))
        XCTAssertNoThrow(try transaction.change(status: .signing))
        XCTAssertNoThrow(try transaction.change(status: .discarded))
        XCTAssertNoThrow(try transaction.change(status: .draft))
        XCTAssertNoThrow(try transaction.change(status: .discarded))
    }

    func test_whenInDraft_thenCanAddSignature() throws {
        givenNewlyCreatedTransaction()
        XCTAssertNoThrow(try transaction.add(signature: signature))
        XCTAssertEqual(transaction.signatures, [signature])
    }

    func test_whenAddingSignatureTwice_thenIgnoresDuplicate() throws {
        givenNewlyCreatedTransaction()
        try transaction.add(signature: signature)
        try transaction.add(signature: signature)
        XCTAssertEqual(transaction.signatures, [signature])
    }

    func test_whenInSigning_thenCanAddSignature() throws {
        try givenSigningTransaction()
        try transaction.add(signature: signature)
    }

    func test_whenNotInDraftOrSigningAndAddsSignature_thenThrowsError() throws {
        givenNewlyCreatedTransaction()
        try transaction.change(status: .discarded)
        XCTAssertThrowsError(try transaction.add(signature: signature))
    }

    func test_whenAddedSignature_thenCanRemoveIt() throws {
        givenNewlyCreatedTransaction()
        try transaction.add(signature: signature)
        try transaction.remove(signature: signature)
        XCTAssertTrue(transaction.signatures.isEmpty)
    }

    func test_whenNotInDraftOrSigning_thenCanNotRemoveSignature() throws {
        try givenSigningTransaction()
        try transaction.change(status: .discarded)
        XCTAssertThrowsError(try transaction.remove(signature: signature))
    }

}

extension TransactionTests {

    private func givenNewlyCreatedTransaction() {
        transaction = Transaction(id: try! TransactionID(),
                                  type: .transfer,
                                  walletID: try! WalletID(),
                                  accountID: AccountID(token: "ETH"))
    }

    private func givenSigningTransaction() throws {
        givenNewlyCreatedTransaction()
        try moveToSigningStatus()
    }

    private func moveToSigningStatus() throws {
        try transaction.change(amount: .ether(0))
        try transaction.change(fee: .ether(0))
        try transaction.change(sender: BlockchainAddress(value: "sender"))
        try transaction.change(recipient: BlockchainAddress(value: "recipient"))
        try transaction.change(status: .signing)
    }

}
