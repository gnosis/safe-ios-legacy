//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel

class ERC20TokenContractProxyTests: XCTestCase {

    func test_encodesSelectorAndParams() throws {
        let nodeService = MockEthereumNodeService1()
        let encryptionService = MockEncryptionService1()
        DomainRegistry.put(service: nodeService, for: EthereumNodeDomainService.self)
        DomainRegistry.put(service: encryptionService, for: EncryptionDomainService.self)

        let proxy = ERC20TokenContractProxy()
        let expectedBalance = TokenInt(150)
        let selector = "balanceOf(address)".data(using: .ascii)!
        let expectedHash = Data(repeating: 3, count: 32)
        encryptionService.expect_hash(selector, result: expectedHash)

        let methodCall = expectedHash.prefix(4) + Data(ethHex: Address.safeAddress.value).leftPadded(to: 32)
        let balanceHex = Data(ethHex: expectedBalance.hexString)
        let balance32Bytes = Data(repeating: 0, count: 32 - balanceHex.count) + balanceHex
        nodeService.expect_eth_call(to: Address.testAccount1, data: methodCall, result: balance32Bytes)

        let balance = try proxy.balance(of: Address.safeAddress, contract: Address.testAccount1)

        XCTAssertEqual(balance, expectedBalance)
        nodeService.verify()
        encryptionService.verify()
    }

}
