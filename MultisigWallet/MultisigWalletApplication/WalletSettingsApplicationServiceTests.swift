//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletApplication
import MultisigWalletDomainModel

class WalletSettingsApplicationServiceTests: XCTestCase {

    let mockReplaceService = MockReplaceBrowserExtensionDomainService()
    let mockWalletService = MockWalletApplicationService()
    let service = WalletSettingsApplicationService()

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: mockReplaceService, for: ReplaceBrowserExtensionDomainService.self)
        ApplicationServiceRegistry.put(service: mockWalletService, for: WalletApplicationService.self)
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

}

class MockReplaceBrowserExtensionDomainService: ReplaceBrowserExtensionDomainService {

    var newOwnerAddressReesult: String?

    override func newOwnerAddress(from transactionID: TransactionID) -> String? {
        return newOwnerAddressReesult
    }

    var updateArguments: (tx: TransactionID, address: String)?
    override func update(transaction: TransactionID, newOwnerAddress: String) {
        updateArguments = (transaction, newOwnerAddress)
    }

}
