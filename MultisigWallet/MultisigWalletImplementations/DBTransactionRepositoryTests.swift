//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletImplementations
import MultisigWalletDomainModel
import Database

class DBTransactionRepositoryTests: XCTestCase {

    var db: SQLiteDatabase!
    var repo: DBTransactionRepository!

    override func setUp() {
        super.setUp()
        db = SQLiteDatabase(name: String(reflecting: self),
                            fileManager: FileManager.default,
                            sqlite: CSQLite3(),
                            bundleId: String(reflecting: self))
        try? db.destroy()
        try! db.create()
        repo = DBTransactionRepository(db: db)
        repo.setUp()
    }

    override func tearDown() {
        super.tearDown()
        try? db.destroy()
    }

    func test_oneTransaction() throws {
        let transaction = testTransaction()

        repo.save(transaction)
        let saved = repo.findByID(transaction.id)
        let byHash = repo.findBy(hash: transaction.hash!, status: transaction.status)

        assertEqual(saved, transaction)
        assertEqual(byHash, transaction)

        repo.remove(transaction)
        XCTAssertNil(repo.findByID(transaction.id))
    }

    private func assertEqual(_ lhs: Transaction?, _ rhs: Transaction, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(lhs, rhs, file: file, line: line)
        XCTAssertEqual(lhs?.type, rhs.type, file: file, line: line)
        XCTAssertEqual(lhs?.walletID, rhs.walletID, file: file, line: line)
        XCTAssertEqual(lhs?.amount, rhs.amount, file: file, line: line)
        XCTAssertEqual(lhs?.fee, rhs.fee, file: file, line: line)
        XCTAssertEqual(lhs?.feeEstimate, rhs.feeEstimate, file: file, line: line)
        XCTAssertEqual(lhs?.sender, rhs.sender, file: file, line: line)
        XCTAssertEqual(lhs?.recipient, rhs.recipient, file: file, line: line)
        XCTAssertEqual(lhs?.data, rhs.data, file: file, line: line)
        XCTAssertEqual(lhs?.hash, rhs.hash, file: file, line: line)
        XCTAssertEqual(lhs?.operation, rhs.operation, file: file, line: line)
        XCTAssertEqual(lhs?.nonce, rhs.nonce, file: file, line: line)
        XCTAssertEqual(lhs?.signatures, rhs.signatures, file: file, line: line)
        XCTAssertEqual(lhs?.createdDate, rhs.createdDate, file: file, line: line)
        XCTAssertEqual(lhs?.updatedDate, rhs.updatedDate, file: file, line: line)
        XCTAssertEqual(lhs?.rejectedDate, rhs.rejectedDate, file: file, line: line)
        XCTAssertEqual(lhs?.submittedDate, rhs.submittedDate, file: file, line: line)
        XCTAssertEqual(lhs?.processedDate, rhs.processedDate, file: file, line: line)
        XCTAssertEqual(lhs?.transactionHash, rhs.transactionHash, file: file, line: line)
        XCTAssertEqual(lhs?.status, rhs.status, file: file, line: line)
    }

    private func testTransaction(_ date: Date = Date()) -> Transaction {
        return txWithoutTimestamps()
            .timestampCreated(at: date)
            .timestampUpdated(at: date)
            .timestampRejected(at: date)
            .timestampSubmitted(at: date)
            .timestampProcessed(at: date)
    }

    private func txWithoutTimestamps() -> Transaction {
        return txSigning()
            .change(status: .pending)
            .change(status: .success)
    }

    private func txDraft() -> Transaction {
        let walletID = WalletID()
        let accountID = AccountID(tokenID: Token.gno.id, walletID: walletID)
        return Transaction(id: repo.nextID(), type: .transfer, walletID: walletID, accountID: accountID)
            .change(amount: .ether(3))
            .change(fee: .ether(1))
            .change(feeEstimate: TransactionFeeEstimate(gas: 100, dataGas: 100, gasPrice: .ether(5)))
            .change(sender: Address.testAccount1)
            .change(recipient: Address.testAccount2)
            .change(data: Data(repeating: 1, count: 8))
            .change(nonce: "123")
            .change(hash: Data(repeating: 1, count: 32))
            .change(operation: .delegateCall)
    }

    private func txSigning() -> Transaction {
        return txDraft()
            .change(status: .signing)
            .add(signature: Signature(data: Data(repeating: 1, count: 7),
                                      address: Address.testAccount3))
            .add(signature: Signature(data: Data(repeating: 2, count: 7),
                                      address: Address.testAccount4))
            .set(hash: TransactionHash("hash"))
    }

    private func txPending() -> Transaction {
        return txSigning()
            .change(status: .pending)
    }

    private func txSuccess() -> Transaction {
        return txPending()
            .change(status: .success)
    }

    func test_findAll() {
        let txDraft = self.txDraft()
        let txSigning = self.txSigning()
        let txDiscarded = testTransaction().change(status: .discarded)
        let txPending = self.txPending()
        let txRejected = self.txSigning().change(status: .rejected)
        let txSuccess = self.txSuccess()
        let txFailed = self.txPending().change(status: .failed)

        let txs = [txDraft, txSigning, txDiscarded, txPending, txRejected, txSuccess, txFailed]
        txs.forEach { repo.save($0) }

        let found = repo.findAll()

        XCTAssertEqual(found, txs)
    }

}
