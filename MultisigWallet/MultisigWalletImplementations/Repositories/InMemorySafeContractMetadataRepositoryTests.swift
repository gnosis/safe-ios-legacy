//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletImplementations
import MultisigWalletDomainModel

class InMemorySafeContractMetadataRepositoryTests: XCTestCase {

    func test_latestMasterCopy() {
        // note: empty metadata will crash the app.
        let one = SafeContractMetadata(multiSendContractAddress: .testAccount1,
                                       proxyFactoryAddress: .testAccount1,
                                       safeFunderAddress: .testAccount1,
                                       metadata: [MasterCopyMetadata(address: .testAccount2,
                                                                     version: "1",
                                                                     txTypeHash: Data(),
                                                                     domainSeparatorHash: Data(),
                                                                     proxyCode: Data())])
        let repo1 = InMemorySafeContractMetadataRepository(metadata: one)
        XCTAssertEqual(repo1.latestMasterCopyAddress.value.lowercased(), Address.testAccount2.value.lowercased())

        // many
        let many = SafeContractMetadata(multiSendContractAddress: .testAccount1,
                                        proxyFactoryAddress: .testAccount1,
                                        safeFunderAddress: .testAccount1,
                                        metadata: [MasterCopyMetadata(address: .testAccount2,
                                                                      version: "1",
                                                                      txTypeHash: Data(),
                                                                      domainSeparatorHash: Data(),
                                                                      proxyCode: Data()),
                                                   MasterCopyMetadata(address: .testAccount2,
                                                                      version: "2",
                                                                      txTypeHash: Data(),
                                                                      domainSeparatorHash: Data(),
                                                                      proxyCode: Data()),
                                                   MasterCopyMetadata(address: .testAccount3,
                                                                      version: "3",
                                                                      txTypeHash: Data(),
                                                                      domainSeparatorHash: Data(),
                                                                      proxyCode: Data())])
        let repo2 = InMemorySafeContractMetadataRepository(metadata: many)
        XCTAssertEqual(repo2.latestMasterCopyAddress.value.lowercased(), Address.testAccount3.value.lowercased())
    }

    func test_whenMasterCopyIsKnownOldOne_thenIsOldMasterCopyTrue() {
        let metadata = SafeContractMetadata(multiSendContractAddress: .testAccount1,
                                            proxyFactoryAddress: .testAccount1,
                                            safeFunderAddress: .testAccount1,
                                            metadata: [MasterCopyMetadata(address: .testAccount1,
                                                                          version: "1",
                                                                          txTypeHash: Data(),
                                                                          domainSeparatorHash: Data(),
                                                                          proxyCode: Data()),
                                                       MasterCopyMetadata(address: .testAccount2,
                                                                          version: "2",
                                                                          txTypeHash: Data(),
                                                                          domainSeparatorHash: Data(),
                                                                          proxyCode: Data()),
                                                       MasterCopyMetadata(address: .testAccount3,
                                                                          version: "3",
                                                                          txTypeHash: Data(),
                                                                          domainSeparatorHash: Data(),
                                                                          proxyCode: Data())])
        let repo = InMemorySafeContractMetadataRepository(metadata: metadata)

        XCTAssertTrue(repo.isOldMasterCopy(address: .testAccount1))
        XCTAssertTrue(repo.isOldMasterCopy(address: .testAccount2))
        XCTAssertFalse(repo.isOldMasterCopy(address: .testAccount3))

        let unknownMasterCopy = Address.testAccount4
        XCTAssertFalse(repo.isOldMasterCopy(address: unknownMasterCopy))
    }

}
