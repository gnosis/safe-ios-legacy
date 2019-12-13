//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel
import MultisigWalletImplementations

class ContractUpgradeDomainServiceTests: BaseBrowserExtensionModificationTestCase {

    let service = ContractUpgradeDomainService()
    let newMasterCopy = Address.testAccount2

    override func setUp() {
        super.setUp()
        let metadata = SafeContractMetadata.metadataWithMasterCopy(newMasterCopy)
        let repo = InMemorySafeContractMetadataRepository(metadata: metadata)
        DomainRegistry.put(service: repo, for: SafeContractMetadataRepository.self)
        DomainRegistry.put(service: MockEventPublisher(), for: EventPublisher.self)
    }

    func test_isAvailable() {
        let mockRepo = MockSafeContractMetadataRepository()
        DomainRegistry.put(service: mockRepo, for: SafeContractMetadataRepository.self)

        DomainRegistry.put(service: MockEventPublisher(), for: EventPublisher.self)

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

        let data = service.realTransactionData()
        let proxy = GnosisSafeContractProxy(.safeAddress)
        let changeContractData = proxy.changeMasterCopy(.testAccount2)
        let setFallbackHandlerData = proxy.setFallbackHandler(address: .testAccount1)
        let expectedData = MultiSendContractProxy(.testAccount1).multiSend([
            (operation: .call, to: .safeAddress, value: 0, data: changeContractData),
            (operation: .call, to: .safeAddress, value: 0, data: setFallbackHandlerData)
        ])

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

        // simulate existing "contractUpgrade" transaction to new master copy address
        let txRepo = InMemoryTransactionRepository()
        DomainRegistry.put(service: txRepo, for: TransactionRepository.self)
        let tx = Transaction(id: TransactionID(),
                             type: .contractUpgrade,
                             accountID: AccountID(tokenID: Token.Ether.id, walletID: wallet.id))

        tx.change(data: service.realTransactionData())
        tx.change(status: .success)
        txRepo.save(tx)

        // set up monitoring
        let monitorRepo = MockRBETransactionMonitorRepository()
        DomainRegistry.put(service: monitorRepo, for: RBETransactionMonitorRepository.self)

        try service.postProcess(transactionID: tx.id)

        XCTAssertEqual(wallet.masterCopyAddress.value.lowercased(), newMasterCopy.value.lowercased())
        XCTAssertEqual(wallet.contractVersion, "1.1.1")
    }

    func test_validateOwners_doesNothing() {
        XCTAssertNoThrow(try service.validateOwners(), "Unexpected throw")
    }

}

fileprivate extension SafeContractMetadata {

    static func metadataWithMasterCopy(_ address: Address) -> SafeContractMetadata {
        return SafeContractMetadata(multiSendContractAddress: .testAccount1,
                                    proxyFactoryAddress: .testAccount1,
                                    proxyCode: Data(),
                                    defaultFallbackHandlerAddress: .testAccount1,
                                    safeFunderAddress: .testAccount1,
                                    metadata: [MasterCopyMetadata(address: address,
                                                                  version: "1.1.1",
                                                                  txTypeHash: Data(),
                                                                  domainSeparatorHash: Data())])
    }

}
