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
    let portfolioRepo = InMemorySinglePortfolioRepository()
    var walletID: WalletID!
    let transactionRepo = InMemoryTransactionRepository()

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: nodeService, for: EthereumNodeDomainService.self)
        DomainRegistry.put(service: eventPublisher, for: EventPublisher.self)
        DomainRegistry.put(service: repo, for: TransactionRepository.self)
        DomainRegistry.put(service: portfolioRepo, for: SinglePortfolioRepository.self)
        DomainRegistry.put(service: transactionRepo, for: TransactionRepository.self)
        walletID = WalletID()
        let portfolio = Portfolio(id: PortfolioID(),
                                  wallets: WalletIDList([walletID]),
                                  selectedWallet: walletID)
        portfolioRepo.save(portfolio)
        tx = Transaction(id: repo.nextID(),
                         type: .transfer,
                         accountID: AccountID(tokenID: Token.Ether.id, walletID: walletID))

    }

    func test_whenRemovingDraft_thenRemoves() {
        repo.save(tx)
        service.removeDraftTransaction(tx.id)
        XCTAssertNil(repo.find(id: tx.id))
    }

    func test_whenStatusIsNotDraft_thenDoesNotRemovesTransaction() {
        tx = Transaction.rejected()
        repo.save(tx)
        service.removeDraftTransaction(tx.id)
        XCTAssertNotNil(repo.find(id: tx.id))
    }

    func test_whenSameTimestamps_thenOrdersByStatus() {
        let date = Date()
        let stored = [Transaction.pending().allTimestamps(at: date),
                      Transaction.failure().allTimestamps(at: date),
                      Transaction.pending().allTimestamps(at: date),
                      Transaction.success().allTimestamps(at: date)]
        save(stored)
        let all = service.allTransactions()
        let expected = stored.sorted { lhs, rhs in
            if lhs.status == rhs.status {
                return lhs.id.id < rhs.id.id
            } else {
                return lhs.status.rawValue < rhs.status.rawValue
            }
        }
        XCTAssertEqual(all.first, expected.first)
        XCTAssertEqual(all, expected)
    }

    private func save(_ values: [Transaction]) {
        for v in values {
            repo.save(v)
        }
    }

    func test_whenCertainStatus_thenIgnores() {
        let stored = [Transaction.pending(), .draft(), .signing()]
        save(stored)
        XCTAssertEqual(service.allTransactions(), [stored[0]])
    }

    func test_whenOnlyOneTimestamp_thenUsesWhatExists() {
        let stored = [
            Transaction.pending().timestampSubmitted(at: Date(timeIntervalSince1970: 1)),
            Transaction.failure().timestampProcessed(at: Date(timeIntervalSince1970: 2)),
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
        for t in repo.all() {
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
        let tx = repo.find(id: stored[0].id)!
        XCTAssertNotNil(tx.processedDate)
    }

    func test_whenFailedStatus_thenUpdatesTxStatusAndTimestamp() throws {
        let stored = [Transaction.pending()]
        save(stored)
        nodeService.expect_eth_getTransactionReceipt(transaction: stored[0].transactionHash!, receipt: .failed)

        try service.updatePendingTransactions()

        let tx = repo.find(id: stored[0].id)!
        XCTAssertEqual(tx.status, .failed)
        XCTAssertNotNil(tx.processedDate)
    }

    func test_whenCleansUp_thenRemovesAllNotSubmittedTransactions() {
        // TODO: TransactionStatus.Code.allCases
        let allStatuses = [TransactionStatus.Code.draft, .signing, .pending, .rejected, .failed, .success]
        let doNotCleanUpStatuses = [TransactionStatus.Code.pending, .rejected, .failed, .success]
        for status in allStatuses {
            transactionRepo.save(createTransaction(status: status))
        }
        let doNotCleanUpTransactions = transactionRepo.all().filter { doNotCleanUpStatuses.contains($0.status) }

        service.cleanUpStaleTransactions()

        for tx in doNotCleanUpTransactions {
            XCTAssertNotNil(transactionRepo.find(id: tx.id))
        }
    }

    private func createTransaction(status: TransactionStatus.Code) -> Transaction {
        let tx = Transaction.draft()
        tx.change(status: status)
        return tx
    }

}

extension TransactionReceipt {

    static let success = TransactionReceipt(hash: TransactionHash.test1, status: .success, blockHash: "0x1")
    static let failed = TransactionReceipt(hash: TransactionHash.test1, status: .failed, blockHash: "0x1")

}

extension Transaction {

    static func success() -> Transaction {
        return pending().succeed()
    }

    static func failure() -> Transaction {
        return pending().fail()
    }

    static func pending() -> Transaction {
        return signing().proceed()
    }

    static func rejected() -> Transaction {
        return signing().reject()
    }

    static func signing() -> Transaction {
        return draft()
            .proceed()
            .add(signature: Signature(data: Data(), address: Address.testAccount1))
            .set(hash: TransactionHash.test1)
    }

    static func draft() -> Transaction {
        return bare()
            .change(amount: .ether(1))
            .change(fee: .ether(1))
            .change(feeEstimate: TransactionFeeEstimate(gas: 1, dataGas: 1, operationalGas: 1, gasPrice: .ether(1)))
            .change(sender: Address.testAccount1)
            .change(recipient: Address.testAccount2)
            .change(data: Data())
            .change(nonce: "1")
            .change(hash: Data())
            .change(operation: .call)
    }

    static func bare() -> Transaction {
        let walletID = DomainRegistry.portfolioRepository.portfolio()!.selectedWallet!
        let accountID = AccountID(tokenID: Token.Ether.id, walletID: walletID)
        return Transaction(id: TransactionID(),
                           type: .transfer,
                           accountID: accountID)
    }

    func allTimestamps(at date: Date) -> Transaction {
        return timestampProcessed(at: date)
            .timestampSubmitted(at: date)
            .timestampRejected(at: date)
            .timestampUpdated(at: date)
            .timestampCreated(at: date)
    }
}
