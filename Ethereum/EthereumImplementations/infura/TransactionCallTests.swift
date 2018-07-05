//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import EthereumImplementations
import BigInt

class TransactionCallTests: XCTestCase {

    func test_ethAddress() throws {
        let zero = EthAddress.zero
        XCTAssertEqual(zero.data.count, 20)

        let moreThan20Bytes = EthAddress(Data(repeating: 1, count: 25))
        let expectedMoreThan20Bytes = EthAddress(Data(repeating: 1, count: 20))
        XCTAssertEqual(moreThan20Bytes, expectedMoreThan20Bytes)

        XCTAssertTrue(zero.mixedCaseChecksumEncoded.hasPrefix("0x"))
        XCTAssertEqual(zero.hexString, "0x0000000000000000000000000000000000000000")

        struct Box: Codable {
            var data: EthAddress
        }

        let b = Box(data: EthAddress.zero)
        let data = try JSONEncoder().encode(b)
        let decoded = try JSONDecoder().decode(Box.self, from: data)
        XCTAssertEqual(decoded.data, b.data)

        let fromHex = EthAddress(hex: "0xabcdef44556677889900abcdef44556677889900")
        XCTAssertEqual(fromHex.data, Data(hex: "0xabcdef44556677889900abcdef44556677889900"))
        XCTAssertEqual(fromHex.data, Data(hex: fromHex.mixedCaseChecksumEncoded))
        XCTAssertEqual(fromHex.mixedCaseChecksumEncoded, "0xaBcdeF44556677889900ABcdef44556677889900")
    }

    func test_ethData() throws {
        let source = Data(repeating: 1, count: 12)
        let data = EthData(source)
        XCTAssertEqual(data.data, source)
        XCTAssertEqual(data.hexString, "0x010101010101010101010101")

        let paddedTo100 = data.padded(to: 100)
        XCTAssertEqual(paddedTo100.data, Data(repeating: 0, count: 100 - 12) + source)

        let paddedTo10 = data.padded(to: 10)
        XCTAssertEqual(paddedTo10.data, source.suffix(10))

        struct Box: Codable {
            var data: EthData
        }

        let b = Box(data: EthData(hex: "0xF"))
        let encoded = try JSONEncoder().encode(b)
        let decoded = try JSONDecoder().decode(Box.self, from: encoded)
        XCTAssertEqual(decoded.data, b.data)
    }

    func test_transactionCall() throws {
        let call = TransactionCall(from: .zero,
                                   to: EthAddress(hex: "0x01"),
                                   gas: 0xff,
                                   gasPrice: 0xee,
                                   value: 0xbb,
                                   data: EthData(hex: "0xdD"))
        let encoded = try JSONEncoder().encode(call)
        let json = String(data: encoded, encoding: .utf8)!
        XCTAssertTrue(json.contains("0x0000000000000000000000000000000000000000"))
        XCTAssertTrue(json.contains("0x0000000000000000000000000000000000000001"))
        XCTAssertTrue(json.localizedCaseInsensitiveContains("0xFF"))
        XCTAssertTrue(json.localizedCaseInsensitiveContains("0xEE"))
        XCTAssertTrue(json.localizedCaseInsensitiveContains("0xBB"))
        XCTAssertTrue(json.localizedCaseInsensitiveContains("0xDD"))
    }
}
