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

    let proxy = EthereumContractProxy(Address.testAccount1)

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
    func test_whenDecodingUIntEmptyData_thenReturns0() {
        XCTAssertEqual(proxy.decodeUInt(Data()), 0)
    }

    func test_whenEncodingTupleUInt_thenEncodesToData() {
        let values = (0..<3).map { i in BigUInt(2) ^ (1 + i) }
        let rawValues = values.map { proxy.encodeUInt($0) }.reduce(into: Data()) { $0.append($1) }
        XCTAssertEqual(rawValues.count, 3 * 32)

        XCTAssertEqual(proxy.encodeTupleUInt(values), rawValues)
    }

    func test_whenDataIsEmpty_thenDecodingReturnsEmptyValue() {
        XCTAssertEqual(proxy.decodeArrayAddress(Data()), [])
        XCTAssertEqual(proxy.decodeArrayUInt(Data()), [])
        XCTAssertEqual(proxy.decodeTupleUInt(Data(), 0), [])
        XCTAssertEqual(proxy.decodeTupleUInt(Data(), 1), [])
    }

    func test_whenDecodingTupleOfStaticTypes_thenDecodesAsArray() {
        let values = (0..<3).map { i in BigUInt(2) ^ (1 + i) }
        XCTAssertEqual(proxy.decodeTupleUInt(proxy.encodeTupleUInt(values), values.count), values)
    }

    func test_whenEncodingArrayUInt_thenEncodesToData() {
        let values = (0..<3).map { i in BigUInt(2) ^ (1 + i) }
        let offsetToData = proxy.encodeUInt(32)
        let count = proxy.encodeUInt(3)
        let items = values.map { proxy.encodeUInt($0) }.reduce(into: Data()) { $0.append($1) }
        let rawValues = offsetToData + count + items
        XCTAssertEqual(proxy.encodeArrayUInt(values), rawValues)
    }

    func test_whenDecodingArrayOfUInts_thenReturnsArray() {
        let values = [BigUInt(1), BigUInt(2), BigUInt(3)]
        XCTAssertEqual(proxy.decodeArrayUInt(proxy.encodeArrayUInt(values)), values)
    }

    func test_whenEncodesDecodesAddress_thenUsesUInt() {
        let values = [Address.testAccount1, Address.testAccount2]
        let uints = values.map { BigUInt(Data(ethHex: $0.value)) }
        XCTAssertEqual(proxy.encodeArrayAddress(values), proxy.encodeArrayUInt(uints))
    }

    func test_whenDecodesAddress_thenReturnsIt() {
        let rawValue = proxy.encodeUInt(BigUInt(Data(ethHex: Address.testAccount1.value)))
        XCTAssertEqual(proxy.decodeAddress(rawValue).value.lowercased(), Address.testAccount1.value.lowercased())
    }

    func test_whenEncodesAddress_thenReturnsData() {
        XCTAssertEqual(proxy.encodeAddress(Address.testAccount1),
                       proxy.encodeUInt(BigUInt(Data(ethHex: Address.testAccount1.value))))
    }

    func test_whenEncodesDecodesBool_thenDoesItCorrectly() {
        XCTAssertEqual(proxy.encodeBool(true), proxy.encodeUInt(1))
        XCTAssertEqual(proxy.encodeBool(false), proxy.encodeUInt(0))
        XCTAssertEqual(proxy.decodeBool(Data()), false)
        XCTAssertEqual(proxy.decodeBool(proxy.encodeUInt(123)), true)
        XCTAssertEqual(proxy.decodeBool(proxy.encodeUInt(1)), true)
        XCTAssertEqual(proxy.decodeBool(proxy.encodeUInt(0)), false)
    }

    func test_encodeBytes() {
        let shorterThan32Bytes = Data([0x01])
        let exactly32Bytes = Data(repeating: 0xa, count: 32)
        let multipleOf32Bytes = Data(repeating: 0xb, count: 64)
        let remainderShorterThan32Bytes = Data(repeating: 0xc, count: 33)

        XCTAssertEqual(proxy.encodeBytes(shorterThan32Bytes),
                       proxy.encodeUInt(BigUInt(shorterThan32Bytes.count)) +
                       shorterThan32Bytes.rightPadded(to: 32))

        XCTAssertEqual(proxy.encodeBytes(exactly32Bytes),
                       proxy.encodeUInt(BigUInt(exactly32Bytes.count)) +
                       exactly32Bytes)

        XCTAssertEqual(proxy.encodeBytes(multipleOf32Bytes),
                       proxy.encodeUInt(BigUInt(multipleOf32Bytes.count)) +
                       multipleOf32Bytes)

        XCTAssertEqual(proxy.encodeBytes(remainderShorterThan32Bytes),
                       proxy.encodeUInt(BigUInt(remainderShorterThan32Bytes.count)) +
                       remainderShorterThan32Bytes.rightPadded(to: 64))

        XCTAssertEqual(proxy.decodeBytes(proxy.encodeBytes(shorterThan32Bytes)), shorterThan32Bytes)
        XCTAssertEqual(proxy.decodeBytes(proxy.encodeBytes(exactly32Bytes)), exactly32Bytes)
        XCTAssertEqual(proxy.decodeBytes(proxy.encodeBytes(multipleOf32Bytes)), multipleOf32Bytes)
        XCTAssertEqual(proxy.decodeBytes(proxy.encodeBytes(remainderShorterThan32Bytes)), remainderShorterThan32Bytes)

    }

}
