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

    func test_oneTransaction() {
        let transaction = testTransaction()

        repo.save(transaction)
        let saved = repo.findByID(transaction.id)
        let byHash = repo.findBy(hash: transaction.hash!, status: transaction.status)

        assertEqual(saved, transaction)
        assertEqual(byHash, transaction)

        repo.remove(transaction)
        XCTAssertNil(repo.findByID(transaction.id))
    }


    func test_transactionWithPartialData() {
        let tx = txDraft().change(feeEstimate: nil)
        repo.save(tx)
        let saved = repo.findByID(tx.id)
        assertEqual(saved, tx)
    }

    private func assertEqual(_ lhs: Transaction?, _ rhs: Transaction, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(lhs, rhs, file: file, line: line)
        guard let lhs = lhs else {
            XCTFail(file: file, line: line)
            return
        }
        XCTAssertEqual(lhs.type, rhs.type, "type", file: file, line: line)
        XCTAssertEqual(lhs.walletID, rhs.walletID, "walletID", file: file, line: line)
        XCTAssertEqual(lhs.amount, rhs.amount, "amount", file: file, line: line)
        XCTAssertEqual(lhs.fee, rhs.fee, "fee", file: file, line: line)
        XCTAssertEqual(lhs.feeEstimate, rhs.feeEstimate, "feeEstimate", file: file, line: line)
        XCTAssertEqual(lhs.sender, rhs.sender, "sender", file: file, line: line)
        XCTAssertEqual(lhs.recipient, rhs.recipient, "recipient", file: file, line: line)
        XCTAssertEqual(lhs.data, rhs.data, "data", file: file, line: line)
        XCTAssertEqual(lhs.hash, rhs.hash, "hash", file: file, line: line)
        XCTAssertEqual(lhs.operation, rhs.operation, "operation", file: file, line: line)
        XCTAssertEqual(lhs.nonce, rhs.nonce, "nonce", file: file, line: line)
        XCTAssertEqual(lhs.signatures, rhs.signatures, "signatures", file: file, line: line)
        XCTAssertEqual(lhs.createdDate, rhs.createdDate, "createdDate", file: file, line: line)
        XCTAssertEqual(lhs.updatedDate, rhs.updatedDate, "updatedDate", file: file, line: line)
        XCTAssertEqual(lhs.rejectedDate, rhs.rejectedDate, "rejectedDate", file: file, line: line)
        XCTAssertEqual(lhs.submittedDate, rhs.submittedDate, "submittedDate", file: file, line: line)
        XCTAssertEqual(lhs.processedDate, rhs.processedDate, "processedDate", file: file, line: line)
        XCTAssertEqual(lhs.transactionHash, rhs.transactionHash, "transactionHash", file: file, line: line)
        XCTAssertEqual(lhs.status, rhs.status, "status", file: file, line: line)
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
            .proceed()
            .succeed()
    }

    private func txDraft() -> Transaction {
        let walletID = WalletID()
        let accountID = AccountID(tokenID: Token.gno.id, walletID: walletID)
        return Transaction(id: repo.nextID(), type: .transfer, walletID: walletID, accountID: accountID)
            .change(amount: .ether(3))
            .change(fee: .ether(1))
            .change(feeEstimate: TransactionFeeEstimate(gas: 100,
                                                        dataGas: 100,
                                                        operationalGas: 100,
                                                        gasPrice: .ether(5)))
            .change(sender: Address.testAccount1)
            .change(recipient: Address.testAccount2)
            .change(data: Data(repeating: 1, count: 8))
            .change(nonce: "123")
            .change(hash: Data(repeating: 1, count: 32))
            .change(operation: .delegateCall)
    }

    private func txSigning() -> Transaction {
        return txDraft()
            .proceed()
            .add(signature: Signature(data: Data(repeating: 1, count: 7),
                                      address: Address.testAccount3))
            .add(signature: Signature(data: Data(repeating: 2, count: 7),
                                      address: Address.testAccount4))
            .set(hash: TransactionHash("hash"))
    }

    private func txPending() -> Transaction {
        return txSigning()
            .proceed()
    }

    private func txSuccess() -> Transaction {
        return txPending()
            .succeed()
    }

    func test_findAll() {
        let txDraft = self.txDraft()
        let txSigning = self.txSigning()
        let txDiscarded = testTransaction().discard()
        let txPending = self.txPending()
        let txRejected = self.txSigning().reject()
        let txSuccess = self.txSuccess()
        let txFailed = self.txPending().fail()

        let txs = [txDraft, txSigning, txDiscarded, txPending, txRejected, txSuccess, txFailed]
        txs.forEach { repo.save($0) }

        let found = repo.findAll()

        XCTAssertEqual(found, txs)
    }

}
