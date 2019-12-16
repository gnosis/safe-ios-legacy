//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel
import MultisigWalletImplementations

class ContractUpgradeDomainServiceTests: BaseBrowserExtensionModificationTestCase {

    let service = ContractUpgradeDomainService()

    func test_isAvailable() {
        let mockRepo = MockSafeContractMetadataRepository()
        DomainRegistry.put(service: mockRepo, for: SafeContractMetadataRepository.self)

        provisionWallet(owners: [.thisDevice, .paperWallet, .paperWalletDerived], threshold: 1)
        wallet.changeMasterCopy(Address.testAccount1)
        DomainRegistry.walletRepository.save(wallet)

        mockRepo.isOldMasterCopy_result = true
        XCTAssertTrue(service.isAvailable)

        mockRepo.isOldMasterCopy_result = false
        XCTAssertFalse(service.isAvailable)
    }

    func test_realTransactionData() {
        DomainRegistry.put(service: EncryptionService(), for: EncryptionDomainService.self)
        provisionWallet(owners: [.thisDevice, .paperWallet, .paperWalletDerived], threshold: 1)

        let metadata = SafeContractMetadata.metadataWithMasterCopy(.testAccount2)
        let repo = InMemorySafeContractMetadataRepository(metadata: metadata)
        DomainRegistry.put(service: repo, for: SafeContractMetadataRepository.self)

        let data = service.realTransactionData()
        let expectedData = WalletProxyContractProxy(.testAccount1).changeMasterCopy(.testAccount2)

        XCTAssertEqual(data, expectedData, "data: \(data.toHexString()) expected: \(expectedData.toHexString())")
    }

    func test_whenProcessingSuccess_thenChangesMasterCopy() throws {
        let oldMasterCopy = Address.testAccount1
        let newMasterCopy = Address.testAccount2

        // set up wallet
        DomainRegistry.put(service: EncryptionService(), for: EncryptionDomainService.self)
        provisionWallet(owners: [.thisDevice, .paperWallet, .paperWalletDerived], threshold: 1)
        wallet.changeMasterCopy(oldMasterCopy)
        DomainRegistry.walletRepository.save(wallet)

        // set up known contract configurations
        let metadata = SafeContractMetadata.metadataWithMasterCopy(newMasterCopy)
        let repo = InMemorySafeContractMetadataRepository(metadata: metadata)
        DomainRegistry.put(service: repo, for: SafeContractMetadataRepository.self)

        // simulate existing "contractUpgrade" transaction to new master copy address
        let txRepo = InMemoryTransactionRepository()
        DomainRegistry.put(service: txRepo, for: TransactionRepository.self)
        let tx = Transaction(id: TransactionID(),
                             type: .contractUpgrade,
                             accountID: AccountID(tokenID: Token.Ether.id, walletID: wallet.id))
        tx.change(data: WalletProxyContractProxy(.testAccount1).changeMasterCopy(.testAccount2))
        tx.change(status: .success)
        txRepo.save(tx)

        // set up monitoring
        let monitorRepo = MockRBETransactionMonitorRepository()
        DomainRegistry.put(service: monitorRepo, for: RBETransactionMonitorRepository.self)

        try service.postProcess(transactionID: tx.id)

        XCTAssertEqual(wallet.masterCopyAddress.value.lowercased(), newMasterCopy.value.lowercased())
        XCTAssertEqual(wallet.contractVersion, "1")
    }

    func test_validateOwners_doesNothing() {
        XCTAssertNoThrow(try service.validateOwners(), "Unexpected throw")
    }

}

fileprivate extension SafeContractMetadata {
    
    static func metadataWithMasterCopy(_ address: Address) -> SafeContractMetadata {
        return SafeContractMetadata(multiSendContractAddress: .testAccount1,
                                    proxyFactoryAddress: .testAccount1,
                                    safeFunderAddress: .testAccount1,
                                    masterCopy: [MasterCopyMetadata(address: address,
                                                                    version: "1",
                                                                    txTypeHash: Data(),
                                                                    domainSeparatorHash: Data(),
                                                                    proxyCode: Data())],
                                    multiSend: [])
    }
    
}
