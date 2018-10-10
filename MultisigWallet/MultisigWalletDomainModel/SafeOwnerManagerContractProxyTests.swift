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

    func test_getOwners() throws {
        let methodCall = proxy.method("getOwners()")
        let addresses = [Address.testAccount2, Address.testAccount3, Address.testAccount4]
        nodeService.expect_eth_call(to: Address.testAccount1,
                                    data: methodCall,
                                    result: proxy.encodeArrayAddress(addresses))
        let result = try proxy.getOwners()
        nodeService.verify()
        XCTAssertEqual(result, addresses.map { Address($0.value.lowercased()) })
    }

    func test_isOwner() throws {
        let methodCall = proxy.method("isOnwer(address)")
        let input = Address.testAccount1
        nodeService.expect_eth_call(to: Address.testAccount1,
                                    data: methodCall + proxy.encodeAddress(input),
                                    result: proxy.encodeBool(true))
        let result = try proxy.isOwner(input)
        nodeService.verify()
        XCTAssertTrue(result)
    }

    func test_getThreshold() throws {
        nodeService.expect_eth_call(to: Address.testAccount1,
                                    data: proxy.method("getThreshold()"),
                                    result: proxy.encodeUInt(3))
        XCTAssertEqual(try proxy.getThreshold(), 3)
        nodeService.verify()
    }

    func test_nonce() throws {
        nodeService.expect_eth_call(to: Address.testAccount1,
                                    data: proxy.method("nonce()"),
                                    result: proxy.encodeUInt(100))
        XCTAssertEqual(try proxy.nonce(), 100)
        nodeService.verify()
    }


}
