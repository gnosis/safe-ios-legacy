//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel

class ReplaceBrowserExtensionDomainServicePostProcessingTests: ReplaceBrowserExtensionDomainServiceBaseTestCase {

    let mockCommunicationService = MockCommunicationDomainService()
    let mockMonitorRepo = MockRBETransactionMonitorRepository()
    var wallet: Wallet!
    var tx: Transaction!

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: mockMonitorRepo, for: RBETransactionMonitorRepository.self)
        DomainRegistry.put(service: mockCommunicationService, for: CommunicationDomainService.self)
        wallet = setUpWallet()
        let txID = service.createTransaction()
        service.addDummyData(to: txID)
        tx = transaction(from: txID)!
    }

    func test_whenTxNotPorcessed_thenDoesNothing() throws {
        let notProcessedStates = [TransactionStatus.Code.draft, .signing, .pending, .rejected]
        for status in notProcessedStates {
            let oldOwner = wallet.owner(role: .browserExtension)!
            tx.change(status: status)

            try service.postProcess(transactionID: tx.id)

            wallet = walletRepo.find(id: wallet.id)!
            XCTAssertEqual(wallet.owner(role: .browserExtension), oldOwner, "Status: \(status)")
        }
    }

    func test_whenTxFailed_thenDeletesNewPair() throws {
        let newOwner = service.newOwnerAddress(from: tx.id)!
        tx.change(status: .failed)

        try service.postProcess(transactionID: tx.id)

        XCTAssertEqual(mockCommunicationService.deletePairArguments?.walletID, wallet.id)
        XCTAssertEqual(mockCommunicationService.deletePairArguments?.other, newOwner)
    }

    func test_whenTxSuccessAndOldOwnerExists_thenDeletesOldPair() throws {
        let oldOwner = wallet.owner(role: .browserExtension)!
        tx.change(status: .success)

        try service.postProcess(transactionID: tx.id)

        XCTAssertEqual(mockCommunicationService.deletePairArguments?.walletID, wallet.id)
        XCTAssertEqual(mockCommunicationService.deletePairArguments?.other, oldOwner.address.value)
    }

    func test_whenTxSuccessAndOldOwnerExists_thenReplacesWithNewOwner() throws {
        let newOwner = service.newOwnerAddress(from: tx.id)!
        let oldOwner = wallet.owner(role: .browserExtension)!
        tx.change(status: .success)

        try service.postProcess(transactionID: tx.id)

        XCTAssertEqual(wallet.owner(role: .browserExtension)?.address.value, newOwner)
        XCTAssertFalse(wallet.contains(owner: oldOwner))
    }

    func test_whenTxSuccessAndNewOwnerNotFound_thenRemovesProcessing() throws {
        tx.change(data: nil)
        try do_testRemovesMonitoring(in: .success)
    }

    func test_whenTxProcessed_thenRemovesMonitoringProcessing() throws {
        try do_testRemovesMonitoring(in: .success)
        try do_testRemovesMonitoring(in: .failed)
    }

    func test_whenTxSuccess_thenNotifiesCreated() throws {
        tx.change(status: .success)
        try service.postProcess(transactionID: tx.id)
        XCTAssertEqual(mockCommunicationService.notifyWalletCreatedId, wallet.id)
    }

    func test_whenTxSuccessButNotificationThrows_thenDoesNotThrow() {
        tx.change(status: .success)
        mockCommunicationService.shouldThrow = true
        XCTAssertNoThrow(try service.postProcess(transactionID: tx.id))
    }

    func test_whenTxSuccess_thenNewOwnerAddressIsFormatted() throws {
        let expected = Address.paperWalletAddress
        mockEncryptionService.addressFromStringResult = expected
        tx.change(status: .success)
        try service.postProcess(transactionID: tx.id)
        XCTAssertEqual(wallet.owner(role: .browserExtension)?.address, expected)
    }

    func do_testRemovesMonitoring(in status: TransactionStatus.Code, line: UInt = #line) throws {
        tx.change(status: status)
        mockMonitorRepo.save(RBETransactionMonitorEntry(transactionID: tx.id, createdDate: Date()))
        try service.postProcess(transactionID: tx.id)
        XCTAssertNil(mockMonitorRepo.find(id: tx.id), line: line)
    }

    func test_whenProcessesTransactions_thenFetchesAll() throws {
        tx.change(status: .success)
        let otherTx = self.transaction(from: service.createTransaction())!
        otherTx.change(status: .failed)
        mockMonitorRepo.save(RBETransactionMonitorEntry(transactionID: tx.id, createdDate: Date()))
        mockMonitorRepo.save(RBETransactionMonitorEntry(transactionID: otherTx.id,
                                                        createdDate: Date(timeIntervalSinceNow: -1)))
        try service.postProcessTransactions()
        XCTAssertTrue(mockMonitorRepo.findAll().isEmpty)
    }

    func test_whenRegister_thenSavesInRepo() {
        service.registerPostProcessing(for: tx.id, timestamp: Date(timeIntervalSince1970: 0))
        XCTAssertNotNil(mockMonitorRepo.find(id: tx.id))
        XCTAssertEqual(mockMonitorRepo.find(id: tx.id)?.createdDate, Date(timeIntervalSince1970: 0))
    }

    func test_whenUnregister_thenRemovesFromRepo() {
        service.registerPostProcessing(for: tx.id, timestamp: Date(timeIntervalSince1970: 0))
        service.unregisterPostProcessing(for: tx.id)
        XCTAssertNil(mockMonitorRepo.find(id: tx.id))
    }

}

class MockCommunicationDomainService: CommunicationDomainService {

    var deletePairArguments: (walletID: WalletID, other: String)?

    override func deletePair(walletID: WalletID, other address: String) throws {
        deletePairArguments = (walletID, address)
    }

    var notifyWalletCreatedId: WalletID?
    var shouldThrow = false

    enum MyError: Error { case error }

    override func notifyWalletCreated(walletID: WalletID) throws {
        if shouldThrow {
            throw MyError.error
        }
        notifyWalletCreatedId = walletID
    }

}

class MockRBETransactionMonitorRepository: RBETransactionMonitorRepository {

    var items = [RBETransactionMonitorEntry]()

    func save(_ entry: RBETransactionMonitorEntry) {
        items.append(entry)
    }

    func remove(_ entry: RBETransactionMonitorEntry) {
        if let index = items.firstIndex(of: entry) {
            items.remove(at: index)
        }
    }

    func find(id: TransactionID) -> RBETransactionMonitorEntry? {
        return items.first { $0.transactionID == id }
    }

    func findAll() -> [RBETransactionMonitorEntry] {
        return items
    }

}
