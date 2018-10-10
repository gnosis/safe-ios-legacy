//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel

class SafeOwnerManagerContractProxyTests: EthereumContractProxyBaseTests {

    let proxy = SafeOwnerManagerContractProxy(Address.testAccount1)

    override func setUp() {
        super.setUp()
        encryptionService.always_return_hash(Data())
    }

    func test_encodesMethodCallDecodesResult() throws {
        let methodCall = proxy.method("getOwners()")
        let addresses = [Address.testAccount2, Address.testAccount3, Address.testAccount4]
        nodeService.expect_eth_call(to: Address.testAccount1,
                                    data: methodCall,
                                    result: proxy.encodeArrayAddress(addresses))
        let result = try proxy.getOwners()
        nodeService.verify()
        XCTAssertEqual(result, addresses.map { Address($0.value.lowercased()) })
    }



}
