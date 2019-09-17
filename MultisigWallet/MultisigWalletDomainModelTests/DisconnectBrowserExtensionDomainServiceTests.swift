//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel
import MultisigWalletImplementations

class DisconnectBrowserExtensionDomainServiceTests: BaseBrowserExtensionModificationTestCase {

    let service = DisconnectTwoFADomainService()
    let communicationService = MockCommunicationDomainService()

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: communicationService, for: CommunicationDomainService.self)
        provisionWallet(owners: [.thisDevice, .browserExtension, .paperWallet, .paperWalletDerived], threshold: 2)
        service.ownerContractProxy = proxy
    }

    func test_isAvailable() {
        XCTAssertTrue(service.isAvailable)
        provisionWallet(owners: [.thisDevice, .paperWallet, .paperWalletDerived], threshold: 1)
        XCTAssertFalse(service.isAvailable)
    }

    func test_txType() {
        XCTAssertEqual(service.transactionType, .disconnectBrowserExtension)
    }

    func test_whenDummyData_thenRemovesOwner() {
        proxy.removeOwnerResult = Data(repeating: 3, count: 32)
        proxy.getOwners_result = wallet.owners.map { $0.address }
        XCTAssertEqual(service.dummyTransactionData(), proxy.removeOwnerResult)
        XCTAssertEqual(proxy.removeOwnerInput?.prevOwner.value.lowercased(),
                       wallet.owner(role: .thisDevice)!.address.value.lowercased())
        XCTAssertEqual(proxy.removeOwnerInput?.owner, wallet.owner(role: .browserExtension)!.address)
        XCTAssertEqual(proxy.removeOwnerInput?.newThreshold, 1)
    }

    func test_whenRealData_thenUsesRemoveOwner() {
        proxy.removeOwnerResult = Data(repeating: 3, count: 32)
        proxy.getOwners_result = wallet.owners.map { $0.address }
        XCTAssertEqual(service.dummyTransactionData(), proxy.removeOwnerResult)
    }

    func test_whenProcessingSuccess_thenRemovesOwner() throws {
        let extensionAddress = wallet.owner(role: .browserExtension)!.address.value
        let txRepo = InMemoryTransactionRepository()
        DomainRegistry.put(service: txRepo, for: TransactionRepository.self)
        let tx = Transaction(id: TransactionID(),
                             type: .disconnectAuthenticator,
                             accountID: AccountID(tokenID: Token.Ether.id, walletID: wallet.id))
        tx.change(status: .success)
        txRepo.save(tx)
        let monitorRepo = MockRBETransactionMonitorRepository()
        DomainRegistry.put(service: monitorRepo, for: RBETransactionMonitorRepository.self)
        try service.postProcess(transactionID: tx.id)
        XCTAssertEqual(communicationService.deletePairArguments?.walletID, wallet.id)
        XCTAssertEqual(communicationService.deletePairArguments?.other, extensionAddress)
        XCTAssertEqual(wallet.confirmationCount, 1)
        XCTAssertNil(wallet.owner(role: .browserExtension))
    }

}
