//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel
import MultisigWalletImplementations

class ENSContractProxyTests: XCTestCase {

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: EncryptionService(), for: EncryptionDomainService.self)
    }

    func test_resolverInterfaceIds() {
        let resolver = ENSResolverContractProxy(.testAccount1)
        XCTAssertEqual(resolver.method(ENSResolverContractProxy.Selectors.supportsInterface), Data(hex: "0x01ffc9a7"))
        XCTAssertEqual(resolver.method(ENSResolverContractProxy.Selectors.address), Data(hex: "0x3b3b57de"))
        XCTAssertEqual(resolver.method(ENSResolverContractProxy.Selectors.name), Data(hex: "0x691f3431"))
    }

}
