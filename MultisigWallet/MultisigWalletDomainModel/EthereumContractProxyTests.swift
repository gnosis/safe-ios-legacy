//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
import BigInt
@testable import MultisigWalletDomainModel

class EthereumContractProxyBaseTests: XCTestCase {

    let nodeService = MockEthereumNodeService1()
    let encryptionService = MockEncryptionService1()

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: nodeService, for: EthereumNodeDomainService.self)
        DomainRegistry.put(service: encryptionService, for: EncryptionDomainService.self)
    }

}

class EthereumContractProxyTests: EthereumContractProxyBaseTests {

    let proxy = EthereumContractProxy()

    func test_selectorToMethodId() {
        let selector = "abc()".data(using: .ascii)!
        let expectedHash = Data(repeating: 3, count: 32)
        encryptionService.expect_hash(selector, result: expectedHash)
        let methodCall = expectedHash.prefix(4)
        XCTAssertEqual(proxy.method("abc()"), methodCall)
    }

    func test_whenEncodingUInt_thenEncodesInto32Bytes() {
        let rawValue = Data(repeating: 0, count: 32 - 160 / 8) + Data(repeating: 0xff, count: 160 / 8)
        let expectedValue = BigUInt(2).power(160) - 1
        XCTAssertEqual(proxy.encodeUInt(expectedValue), rawValue)
    }

    func test_whenEncodingUIntTooBig_thenTakesRightmost32Bytes() {
        let tooBig = BigUInt(2).power(512) - 1
        let remainder = BigUInt(2).power(256) - 1
        XCTAssertEqual(proxy.encodeUInt(tooBig), proxy.encodeUInt(remainder))
    }

    func test_whenDecodingUInt160_thenDecodesAsBigInt() {
        let expectedValue = BigUInt(2).power(160) - 1
        XCTAssertEqual(proxy.decodeUInt(proxy.encodeUInt(expectedValue)), expectedValue)
    }

    func test_whenEncodingTupleUInt_thenEncodesToData() {
        let values = (0..<3).map { i in BigUInt(2) ^ (1 + i) }
        let rawValues = values.map { proxy.encodeUInt($0) }.reduce(into: Data()) { $0.append($1) }
        XCTAssertEqual(rawValues.count, 3 * 32)

        XCTAssertEqual(proxy.encodeTupleUInt(values), rawValues)
    }

    func test_whenDecodingTupleOfStaticTypes_thenDecodesAsArray() {
        let values = (0..<3).map { i in BigUInt(2) ^ (1 + i) }
        XCTAssertEqual(proxy.decodeTupleUInt(proxy.encodeTupleUInt(values), values.count), values)
    }

    func test_whenEncodingArrayUInt_thenEncodesToData() {
        let values = (0..<3).map { i in BigUInt(2) ^ (1 + i) }
        let count = proxy.encodeUInt(BigUInt(3))
        let rawValues = count + values.map { proxy.encodeUInt($0) }.reduce(into: Data()) { $0.append($1) }
        XCTAssertEqual(proxy.encodeArrayUInt(values), rawValues)
    }

    func test_whenDecodingArrayOfUInts_thenReturnsArray() {
        let values = (0..<3).map { i in BigUInt(2) ^ (1 + i) }
        XCTAssertEqual(proxy.decodeArrayUInt(proxy.encodeArrayUInt(values)), values)
    }

}
