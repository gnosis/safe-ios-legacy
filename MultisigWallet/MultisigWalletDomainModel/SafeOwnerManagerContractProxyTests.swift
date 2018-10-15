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

    func test_whenFindingPrevOwner_thenReturnsCorrectOne() throws {
        let methodCall = proxy.method("getOwners()")
        let addresses = [Address.testAccount2, Address.testAccount3, Address.testAccount4]
        for _ in (0..<4) {
            nodeService.expect_eth_call(to: Address.testAccount1,
                                        data: methodCall,
                                        result: proxy.encodeArrayAddress(addresses))
        }
        let expectedResults = [proxy.sentinelAddress, Address.testAccount2, Address.testAccount3]
        for i in (0..<addresses.count) {
            XCTAssertEqual(try proxy.previousOwner(to: addresses[i])?.value.lowercased(),
                           expectedResults[i].value.lowercased())
        }
        XCTAssertNil(try proxy.previousOwner(to: Address.testAccount1))
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

    func test_addOwner() {
        let data = proxy.invocation("addOwnerWithThreshold(address,uint256)",
                                    proxy.encodeAddress(Address.testAccount2),
                                    proxy.encodeUInt(2))
        XCTAssertEqual(proxy.addOwner(Address.testAccount2, newThreshold: 2), data)
    }

    func test_changeThreshold() {
        let data = proxy.invocation("changeThreshold(uint256)", proxy.encodeUInt(1))
        XCTAssertEqual(proxy.changeThreshold(1), data)
    }

    func test_swapOwner() {
        let data = proxy.invocation("swapOwner(address,address,address)",
                                    proxy.encodeAddress(Address.testAccount1),
                                    proxy.encodeAddress(Address.testAccount2),
                                    proxy.encodeAddress(Address.testAccount3))
        XCTAssertEqual(proxy.swapOwner(prevOwner: Address.testAccount1,
                                       old: Address.testAccount2,
                                       new: Address.testAccount3), data)
    }

    func test_removeOwner() {
        let data = proxy.invocation("removeOwner(address,address,uint256)",
                                    proxy.encodeAddress(Address.testAccount1),
                                    proxy.encodeAddress(Address.testAccount2),
                                    proxy.encodeUInt(1))
        XCTAssertEqual(proxy.removeOwner(prevOwner: Address.testAccount1,
                                         owner: Address.testAccount2,
                                         newThreshold: 1), data)
    }


}
