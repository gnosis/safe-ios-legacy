//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel

class SafeOwnerManagerContractProxyTests: EthereumContractProxyBaseTests {

    override func setUp() {
        super.setUp()
        encryptionService.always_return_hash(Data())
    }

    func test_encodesMethodCall() throws {
        let proxy = SafeOwnerManagerContractProxy(Address.testAccount1)
        let methodCall = proxy.method("getOwners()")
        nodeService.expect_eth_call(to: Address.testAccount1, data: methodCall, result: Data())
        _ = try proxy.getOwners()
        nodeService.verify()
    }

}
