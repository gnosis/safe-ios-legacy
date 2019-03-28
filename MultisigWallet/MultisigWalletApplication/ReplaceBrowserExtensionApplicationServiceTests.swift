//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletApplication
import MultisigWalletDomainModel

class ReplaceBrowserExtensionApplicationServiceTests: XCTestCase {

    var mockReplaceService = MockReplaceBrowserExtensionDomainService()
    let mockWalletService = MockWalletApplicationService()
    var service: ReplaceBrowserExtensionApplicationService!

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: mockReplaceService, for: ReplaceBrowserExtensionDomainService.self)
        ApplicationServiceRegistry.put(service: mockWalletService, for: WalletApplicationService.self)
        service = ReplaceBrowserExtensionApplicationService.create()
    }

    func test_whenOldPairNotSet_thenDoesNotDeleteIt() throws {
        mockReplaceService.newOwnerAddressReesult = nil
        try service.connect(transaction: "Some", code: "Code")
        XCTAssertFalse(mockWalletService.deletePairCalled)
    }

    func test_whenDeletePairThrows_thenThrows() {
        mockWalletService.shouldThrow = true
        mockReplaceService.newOwnerAddressReesult = "Some"
        XCTAssertThrowsError(try service.connect(transaction: "tx", code: "code"))
    }

    func test_whenCreatePairThrows_thenThrows() {
        mockWalletService.shouldThrow = true
        XCTAssertThrowsError(try service.connect(transaction: "tx", code: "code"))
    }

    func test_whenCreatedPair_thenUpdatesTransaction() throws {
        mockWalletService.addressBrowserExtensionCodeResult = "address"
        try service.connect(transaction: "tx", code: "code")
        XCTAssertEqual(mockReplaceService.updateArguments?.tx, TransactionID("tx"))
        XCTAssertEqual(mockReplaceService.updateArguments?.address, "address")
    }

    func test_whenSigning_thenEstimatesTransaction() throws {
        let (tx, phrase) = ("tx", "phrase")
        try service.sign(transaction: tx, withPhrase: phrase)
        XCTAssertTrue(mockReplaceService.didCallEstimateFee)
    }

    func test_whenEstimationThrows_thenThrows() {
        do_testThrowing(\.shouldThrow)
    }

    func test_whenSigningThrows_thenThrows() {
        do_testThrowing(\.shouldThrowDuringSigning)
    }

    private func do_testThrowing(_ keyPath: WritableKeyPath<MockReplaceBrowserExtensionDomainService, Bool>,
                                 line: UInt = #line) {
        let (tx, phrase) = ("tx", "phrase")
        mockReplaceService[keyPath: keyPath] = true
        XCTAssertThrowsError(try service.sign(transaction: tx, withPhrase: phrase))
    }

    func test_whenNewAddressInvalidDuringConnecting_thenThrows() {
        mockReplaceService.shouldThrowDuringValidation = true
        XCTAssertThrowsError(try service.connect(transaction: "tx", code: "code"))
    }

    func test_whenStartsMonitoring_thenRegisterPostProcessing() {
        service.startMonitoring(transaction: "some")
        XCTAssertEqual(mockReplaceService.registerPostProcessingId, TransactionID("some"))
    }

}

class MockReplaceBrowserExtensionDomainService: ReplaceBrowserExtensionDomainService {

    var shouldThrowDuringValidation = false
    var shouldThrowDuringSigning = false
    enum MyError: Error { case error }

    var shouldThrow = false
    func throwIfNeeded() throws {
        if shouldThrow {
            throw MyError.error
        }
    }

    var newOwnerAddressReesult: String?

    override func newOwnerAddress(from transactionID: TransactionID) -> String? {
        return newOwnerAddressReesult
    }

    var updateArguments: (tx: TransactionID, address: String)?
    override func update(transaction: TransactionID, newOwnerAddress: String) {
        updateArguments = (transaction, newOwnerAddress)
    }

    var didCallEstimateFee = false
    override func estimateNetworkFee(for transactionID: TransactionID) throws -> TokenAmount {
        try throwIfNeeded()
        didCallEstimateFee = true
        return TokenAmount(amount: 0, token: Token.Ether)
    }

    override func sign(transactionID: TransactionID, with phrase: String) throws {
        if shouldThrowDuringSigning {
            throw MyError.error
        }
    }

    override func validateNewOwnerAddress(_ address: String) throws {
        if shouldThrowDuringValidation {
            throw MyError.error
        }
    }

    var registerPostProcessingId: TransactionID?

    override func registerPostProcessing(for transactionID: TransactionID, timestamp: Date) {
        registerPostProcessingId = transactionID
    }


    override func stepBackToDraft(_ transactionID: TransactionID) {}

}
