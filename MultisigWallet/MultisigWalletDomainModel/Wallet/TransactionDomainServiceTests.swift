//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel
import MultisigWalletImplementations
import CommonTestSupport
import DateTools

class TransactionDomainServiceTests: XCTestCase {

    let repo = InMemoryTransactionRepository()
    let service = TransactionDomainService()
    var tx: Transaction!
    let nodeService = MockEthereumNodeService1()
    let eventPublisher = MockEventPublisher()

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: nodeService, for: EthereumNodeDomainService.self)
        DomainRegistry.put(service: eventPublisher, for: EventPublisher.self)
        DomainRegistry.put(service: repo, for: TransactionRepository.self)
        tx = Transaction(id: repo.nextID(),
                         type: .transfer,
                         walletID: WalletID(),
                         accountID: AccountID(tokenID: Token.Ether.id, walletID: WalletID()))

    }

    func test_whenRemovingDraft_thenRemoves() {
        repo.save(tx)
        service.removeDraftTransaction(tx.id)
        XCTAssertNil(repo.findByID(tx.id))
    }

    func test_whenStatusIsNotDraft_thenDoesNotRemovesTransaction() {
        tx.change(status: .discarded)
        repo.save(tx)
        service.removeDraftTransaction(tx.id)
        XCTAssertNotNil(repo.findByID(tx.id))
    }

    func test_whenNoTimestamps_thenOrdersByStatus() {
        let stored = [Transaction.pending(), .failure(), .rejected(), .pending(), .success()]
        save(stored)
        let all = service.allTransactions()
        let expected = stored.sorted { lhs, rhs in
            if lhs.status == rhs.status {
                return lhs.id.id < rhs.id.id
            } else {
                return lhs.status.rawValue < rhs.status.rawValue
            }
        }
        XCTAssertEqual(all, expected)
    }

    private func save(_ values: [Transaction]) {
        for v in values {
            repo.save(v)
        }
    }

    func test_whenCertainStatus_thenIgnores() {
        let stored = [Transaction.pending(), .draft(), .discarded(), .signing()]
        save(stored)
        XCTAssertEqual(service.allTransactions(), [stored[0]])
    }

    func test_whenOnlyOneTimestamp_thenUsesWhatExists() {
        let stored = [
            Transaction.pending().timestampCreated(at: Date(timeIntervalSince1970: 0)),
            Transaction.pending().timestampUpdated(at: Date(timeIntervalSince1970: 1)),
            Transaction.failure().timestampProcessed(at: Date(timeIntervalSince1970: 2)),
            Transaction.rejected().timestampRejected(at: Date(timeIntervalSince1970: 3)),
            Transaction.pending().timestampSubmitted(at: Date(timeIntervalSince1970: 4)),
            Transaction.success().timestampProcessed(at: Date(timeIntervalSince1970: 5))
        ]
        save(stored)
        XCTAssertEqual(service.allTransactions(), stored.reversed())
    }

    func test_whenMixOfTimestampAndNot_thenWitoutTimestampsAreInTheStart() {
        let stored1 = [
            Transaction.pending(),
            Transaction.success().timestampProcessed(at: Date(timeIntervalSince1970: 1)),
            Transaction.success().timestampProcessed(at: Date(timeIntervalSince1970: 0))
        ]
        save(stored1)
        XCTAssertEqual(service.allTransactions(), stored1)

        removeAll()

        let stored2 = [
            Transaction.success().timestampProcessed(at: Date(timeIntervalSince1970: 1)),
            Transaction.pending(),
            Transaction.success().timestampProcessed(at: Date(timeIntervalSince1970: 0))
        ]
        let expected = [stored2[1], stored2[0], stored2[2]]
        save(stored2)
        XCTAssertEqual(service.allTransactions(), expected)
    }

    func test_whenDatesEqual_thenComparesNextDate() {
        let stored = [
            Transaction.success()
                .timestampProcessed(at: Date(timeIntervalSince1970: 0))
                .timestampSubmitted(at: Date(timeIntervalSince1970: 0))
                .timestampRejected(at: Date(timeIntervalSince1970: 0))
                .timestampUpdated(at: Date(timeIntervalSince1970: 0))
                .timestampCreated(at: Date(timeIntervalSince1970: 1)),
            Transaction.success()
                .timestampProcessed(at: Date(timeIntervalSince1970: 0))
                .timestampSubmitted(at: Date(timeIntervalSince1970: 0))
                .timestampRejected(at: Date(timeIntervalSince1970: 0))
                .timestampUpdated(at: Date(timeIntervalSince1970: 0))
                .timestampCreated(at: Date(timeIntervalSince1970: 0))
        ]
        save(stored)
        XCTAssertEqual(service.allTransactions(), stored)
    }

    private func removeAll() {
        for t in repo.findAll() {
            repo.remove(t)
        }
    }

    func test_whenSingleProcessedTransactionWithDate_thenSingleGroup() {
        let now = Date()
        let stored = [
            Transaction.success().timestampProcessed(at: now)
        ]
        save(stored)
        let expected = [
            TransactionGroup(type: .processed, date: now.dateForGrouping, transactions: stored)
        ]
        XCTAssertEqual(service.grouppedTransactions(), expected)
    }

    func test_whenSinglePendingTransaction_thenSingleGroup() {
        let now = Date()
        let stored = [
            Transaction.pending().timestampSubmitted(at: now)
        ]
        save(stored)
        let expected = [
            TransactionGroup(type: .pending, date: nil, transactions: stored)
        ]
        XCTAssertEqual(service.grouppedTransactions(), expected)
    }

    func test_whenMultipleDates_thenMultipleGroups() {
        let dates = (0..<5).map { i in Date() - i.days }
        let stored = dates.map { d in Transaction.success().timestampProcessed(at: d) }
        save(stored)
        let groups = stored.map { t in
            TransactionGroup(type: .processed,
                             date: t.processedDate?.dateForGrouping,
                             transactions: [t]) }
        XCTAssertEqual(service.grouppedTransactions(), groups)
    }

    func test_whenMultipleInOneDay_thenOneGroup() {
        let dates = (0..<5).map { i in Date(timeIntervalSince1970: 10) - i.seconds }
        let stored = dates.map { d in Transaction.success().timestampProcessed(at: d) }
        save(stored)
        let groups = [
            TransactionGroup(type: .processed,
                             date: dates.first?.dateForGrouping,
                             transactions: stored)
        ]
        XCTAssertEqual(service.grouppedTransactions(), groups)
    }

    func test_whenUpdatingPendingStatus_thenRequestsReciept() throws {
        let stored = [Transaction.pending()]
        save(stored)
        nodeService.expect_eth_getTransactionReceipt(transaction: stored[0].transactionHash!, receipt: .success)
        eventPublisher.expectToPublish(TransactionStatusUpdated.self)

        try service.updatePendingTransactions()

        XCTAssertTrue(eventPublisher.verify())
        nodeService.verify()
        let tx = repo.findByID(stored[0].id)!
        XCTAssertNotNil(tx.processedDate)
    }

    func test_whenFailedStatus_thenUpdatesTxStatusAndTimestamp() throws {
        let stored = [Transaction.pending()]
        save(stored)
        nodeService.expect_eth_getTransactionReceipt(transaction: stored[0].transactionHash!, receipt: .failed)

        try service.updatePendingTransactions()

        let tx = repo.findByID(stored[0].id)!
        XCTAssertEqual(tx.status, .failed)
        XCTAssertNotNil(tx.processedDate)
    }

}

extension TransactionReceipt {

    static let success = TransactionReceipt(hash: TransactionHash.test1, status: .success)
    static let failed = TransactionReceipt(hash: TransactionHash.test1, status: .failed)

}

extension Transaction {

    static func success() -> Transaction {
        return pending().change(status: .success)
    }

    static func failure() -> Transaction {
        return pending().change(status: .failed)
    }

    static func pending() -> Transaction {
        return signing().change(status: .pending)
    }

    static func rejected() -> Transaction {
        return signing().change(status: .rejected)
    }

    static func signing() -> Transaction {
        return draft()
            .change(status: .signing)
            .add(signature: Signature(data: Data(), address: Address.testAccount1))
            .set(hash: TransactionHash.test1)
    }

    static func draft() -> Transaction {
        return bare()
            .change(amount: .ether(1))
            .change(fee: .ether(1))
            .change(feeEstimate: TransactionFeeEstimate(gas: 1, dataGas: 1, gasPrice: .ether(1)))
            .change(sender: Address.testAccount1)
            .change(recipient: Address.testAccount2)
            .change(data: Data())
            .change(nonce: "1")
            .change(hash: Data())
            .change(operation: .call)
    }

    static func discarded() -> Transaction {
        return bare().change(status: .discarded)
    }

    static func bare() -> Transaction {
        let walletID = WalletID()
        let accountID = AccountID(tokenID: Token.Ether.id, walletID: walletID)
        return Transaction(id: TransactionID(),
                           type: .transfer,
                           walletID: walletID,
                           accountID: accountID)
    }

}
