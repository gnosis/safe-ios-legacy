//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel

class ERC20TokenContractProxyTests: EthereumContractProxyBaseTests {

    let proxy = ERC20TokenContractProxy(Address.testAccount1)


    func test_encodesSelectorAndParams() throws {
        let expectedBalance = TokenInt(150)
        let selector = "balanceOf(address)".data(using: .ascii)!
        let expectedHash = Data(repeating: 3, count: 32)
        encryptionService.expect_hash(selector, result: expectedHash)

        let methodCall = expectedHash.prefix(4) + Data(ethHex: Address.safeAddress.value).leftPadded(to: 32)
        let balanceHex = Data(ethHex: expectedBalance.hexString)
        let balance32Bytes = Data(repeating: 0, count: 32 - balanceHex.count) + balanceHex
        nodeService.expect_eth_call(to: Address.testAccount1, data: methodCall, result: balance32Bytes)

        let balance = try proxy.balance(of: Address.safeAddress)

        XCTAssertEqual(balance, expectedBalance)
        nodeService.verify()
        encryptionService.verify()
    }

    func test_whenResultIsInvalidInt_thenItIsConvertedStill() throws {
        encryptionService.expect_hash(Data(), result: Data())
        nodeService.expect_eth_call(to: Address.testAccount1, data: Data(), result: "hello".data(using: .utf8)!)
        XCTAssertNotEqual(try proxy.balance(of: Address.safeAddress), 0)
    }

    func test_whenResultMoreThan32Bytes_thenTakesPrefix() {
        encryptionService.expect_hash(Data(), result: Data())
        nodeService.expect_eth_call(to: Address.testAccount1, data: Data(), result: Data(repeating: 1, count: 64))
        XCTAssertEqual(try proxy.balance(of: Address.safeAddress),
                       TokenInt(Data(repeating: 1, count: 32).toHexString(), radix: 16)!)
    }

    func test_whenTransferring_thenReturnsEncodedCall() {
        encryptionService.always_return_hash(Data())
        let data = proxy.invocation("transfer(address,uint256)",
                                    proxy.encodeAddress(Address.testAccount2),
                                    proxy.encodeUInt(20))
        XCTAssertEqual(proxy.transfer(to: Address.testAccount2, amount: 20), data)
    }

}
