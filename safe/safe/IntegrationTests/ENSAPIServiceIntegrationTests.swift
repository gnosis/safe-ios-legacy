//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe
import MultisigWalletDomainModel
import MultisigWalletImplementations

class ENSAPIServiceIntegrationTests: BlockchainIntegrationTest {

    // rinkeby ENS registry
    let ensService = ENSAPIService(registryAddress: Address("0xe7410170f87102DF0055eB195163A03B7F2Bff4A"))

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: encryptionService, for: EncryptionDomainService.self)
        DomainRegistry.put(service: infuraService, for: EthereumNodeDomainService.self)
    }

    func test_forwardResolution() {
        XCTAssertNoThrow(try {
            let address = try ensService.address(for: "gnosissafeios.test")
            XCTAssertEqual(address, Address("0x2333b4CC1F89a0B4C43e9e733123C124aAE977EE"))
        }())
    }

    func test_reverseResolution() {
        XCTAssertNoThrow(try {
            let name = try ensService.name(for: Address("0x2333b4CC1F89a0B4C43e9e733123C124aAE977EE"))
            XCTAssertEqual(name, "gnosissafeios.test")
        }())
    }

}
