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

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: nodeService, for: EthereumNodeDomainService.self)
        DomainRegistry.put(service: eventPublisher, for: EventPublisher.self)
        DomainRegistry.put(service: repo, for: TransactionRepository.self)
        DomainRegistry.put(service: portfolioRepo, for: SinglePortfolioRepository.self)
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
            repo.save(createTransaction(status: status))
        }
        let doNotCleanUpTransactions = repo.all().filter { doNotCleanUpStatuses.contains($0.status) }

        service.cleanUpStaleTransactions()

        for tx in doNotCleanUpTransactions {
            XCTAssertNotNil(repo.find(id: tx.id))
        }
    }

    private func createTransaction(status: TransactionStatus.Code) -> Transaction {
        let tx = Transaction.draft()
        tx.change(status: status)
        return tx
    }

}

class TransactionDomainServiceBatchedTransactionsTests: XCTestCase {

    let multiSendAddress = Address.testAccount4
    let transactionService = TransactionDomainService()
    let transactionRepo = InMemoryTransactionRepository()
    let walletRepo = InMemoryWalletRepository()
    lazy var metadataRepo = InMemorySafeContractMetadataRepository(metadata:
        SafeContractMetadata(multiSendContractAddress: multiSendAddress,
                             proxyFactoryAddress: Address.testAccount1,
                             safeFunderAddress: Address.testAccount1,
                             masterCopy: [],
                             multiSend: [MultiSendMetadata(address: multiSendAddress, version: 2)]))
    let nodeService = MockEthereumNodeService()
    let ethereumService = EthereumKitEthereumService()
    lazy var encryptionService = EncryptionService(chainId: .any, ethereumService: ethereumService)
    let tokenRepo = InMemoryTokenListItemRepository()
    let accountUpdateService = MockAccountUpdateService()
    lazy var multiSendContract = MultiSendContractProxy(multiSendAddress)
    let portfolioRepo = InMemorySinglePortfolioRepository()

    let walletAddress = Address.testAccount2
    lazy var wallet = Wallet(id: WalletID(), // important for test
        state: .readyToUse,
        owners: OwnerList(),
        address: walletAddress, // important for test
        feePaymentTokenAddress: nil,
        minimumDeploymentTransactionAmount: 0,
        creationTransactionHash: nil,
        confirmationCount: 1,
        masterCopyAddress: nil,
        contractVersion: nil)

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: transactionRepo, for: TransactionRepository.self)
        DomainRegistry.put(service: walletRepo, for: WalletRepository.self)
        DomainRegistry.put(service: metadataRepo, for: SafeContractMetadataRepository.self)
        DomainRegistry.put(service: encryptionService, for: EncryptionDomainService.self)
        DomainRegistry.put(service: tokenRepo, for: TokenListItemRepository.self)
        DomainRegistry.put(service: nodeService, for: EthereumNodeDomainService.self)
        DomainRegistry.put(service: accountUpdateService, for: AccountUpdateDomainService.self)
        DomainRegistry.put(service: portfolioRepo, for: SinglePortfolioRepository.self)

        walletRepo.save(wallet)
    }

    func batchedTx(type: TransactionType, operation: WalletOperation, data: Data?, recipient: Address)
        -> TransactionID {
            let tx = Transaction(id: TransactionID(),
                                 type: type,
                                 accountID: AccountID(tokenID: Token.Ether.id, walletID: wallet.id))
                .change(operation: operation)
                .change(data: data)
                .change(recipient: recipient)
            transactionRepo.save(tx)
            return tx.id
    }

    func test_whenNonMultiSendTransactionParameters_thenNilBatchedTransactions() {
        XCTAssertNil(transactionService.batchedTransactions(in:
            batchedTx(type: .transfer, operation: .delegateCall, data: nil, recipient: multiSendAddress)),
                     "wrong tx type")

        XCTAssertNil(transactionService.batchedTransactions(in:
            batchedTx(type: .batched, operation: .call, data: nil, recipient: multiSendAddress)),
                     "wrong tx operation")

        XCTAssertNil(transactionService.batchedTransactions(in:
            batchedTx(type: .batched, operation: .delegateCall, data: nil, recipient: multiSendAddress)),
                     "nil data")

        XCTAssertNil(transactionService.batchedTransactions(in:
            batchedTx(type: .batched, operation: .delegateCall, data: Data(), recipient: Address.testAccount1)),
                     "wrong tx recipient")

        XCTAssertNil(transactionService.batchedTransactions(in:
            batchedTx(type: .batched, operation: .delegateCall, data: Data(), recipient: multiSendAddress)),
                     "wrong tx data")
    }

    func test_whenMultiSendEmpty_thenEmptyBatchedTransactions() {
        XCTAssertEqual(transactionService.batchedTransactions(in:
            batchedTx(type: .batched,
                      operation: .delegateCall,
                      data: multiSendContract.multiSend([/* empty */]),
                      recipient: multiSendAddress)),
                       [/* empty */])
    }

    func test_whenMultiSendOne_thenOneSubtransaction() {
        guard let subtransactions = transactionService.batchedTransactions(in:
            batchedTx(type: .batched,
                      operation: .delegateCall,
                      data: multiSendContract.multiSend([
                        (operation: .call, to: walletAddress, value: 1, data: Data())]),
                      recipient: multiSendAddress)),
            subtransactions.count == 1 else {
                        XCTFail()
                        return
        }
        XCTAssertEqual(subtransactions[0].operation, .call)
        XCTAssertEqual(subtransactions[0].recipient, Address.testAccount2)
        XCTAssertEqual(subtransactions[0].amount, TokenAmount(amount: 1, token: Token.Ether))
        XCTAssertEqual(subtransactions[0].data, Data())
    }

    func test_whenMultiSendERC20_thenFetchesToken() {
        let erc20Contract = ERC20TokenContractProxy(Address.testAccount3)
        let erc20Data =  erc20Contract.transfer(to: Address.testAccount4, amount: 2)
        let subtransaction: MultiSendTransaction =
            (operation: .call, to: erc20Contract.contract, value: 0, data: erc20Data)
        guard let subtransactions = transactionService.batchedTransactions(in:
            batchedTx(type: .batched,
                      operation: .delegateCall,
                      data: multiSendContract.multiSend([subtransaction]),
                      recipient: multiSendAddress)),
            subtransactions.count == 1 else {
                XCTFail()
                return
        }
        XCTAssertEqual(subtransactions[0].recipient?.value.lowercased(), Address.testAccount4.value.lowercased())
        XCTAssertEqual(subtransactions[0].amount,
                       TokenAmount(amount: 2, token: transactionService.token(for: erc20Contract.contract)))
        XCTAssertEqual(subtransactions[0].data, erc20Data)
    }

    func test_whenMultiSendMultiple_thenMultipleSubtransactions() {
        guard let subtransactions = transactionService.batchedTransactions(in:
            batchedTx(type: .batched,
                      operation: .delegateCall,
                      data: multiSendContract.multiSend([
                        (operation: .call, to: walletAddress, value: 1, data: Data()),
                        (operation: .call, to: walletAddress, value: 1, data: Data()),
                        (operation: .call, to: walletAddress, value: 1, data: Data())]),
                      recipient: multiSendAddress)) else {
                        XCTFail()
                        return
        }
        XCTAssertEqual(subtransactions.count, 3)
    }

    func test_whenSafeSubtransactions_thenMultiSendIsSafe() {
        // empty is safe
        XCTAssertFalse(transactionService.isDangerous(
            batchedTx(type: .batched,
                      operation: .delegateCall,
                      data: multiSendContract.multiSend([
                        /* empty */
                      ]),
                      recipient: multiSendAddress)))

        // when call to non-safe address with non-empty data and 0 value
        XCTAssertFalse(transactionService.isDangerous(
        batchedTx(type: .batched,
                  operation: .delegateCall,
                  data: multiSendContract.multiSend([
                    (operation: .call, to: Address.testAccount3, value: 0, data: Data([1, 2, 3, 4])),
                  ]),
                  recipient: multiSendAddress)))

        // when call to safe address with value and empty data
        XCTAssertFalse(transactionService.isDangerous(
        batchedTx(type: .batched,
                  operation: .delegateCall,
                  data: multiSendContract.multiSend([
                    (operation: .call, to: walletAddress, value: 1, data: Data()),
                  ]),
                  recipient: multiSendAddress)))

    }

    func test_whenDangerousSubtransactions_thenMultiSendIsDangerous() {
        // if delegate call
        XCTAssertTrue(transactionService.isDangerous(
        batchedTx(type: .batched,
                  operation: .delegateCall,
                  data: multiSendContract.multiSend([
                    (operation: .delegateCall, to: Address.testAccount3, value: 0, data: Data([1, 2, 3, 4])),
                  ]),
                  recipient: multiSendAddress)))

        // if call to the safe address and non-empty data
        XCTAssertTrue(transactionService.isDangerous(
        batchedTx(type: .batched,
                  operation: .delegateCall,
                  data: multiSendContract.multiSend([
                    (operation: .call, to: walletAddress, value: 0, data: Data([1, 2, 3, 4])),
                  ]),
                  recipient: multiSendAddress)))
    }

    func test_whenSafeTransactionParameters_thenItIsNotDangerous() {
        // non-batch
        XCTAssertFalse(transactionService.isDangerous(
        batchedTx(type: .transfer,
                  operation: .call,
                  data: ERC20TokenContractProxy(Address.testAccount4).transfer(to: walletAddress, amount: 1),
                  recipient: Address.testAccount4)))
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
