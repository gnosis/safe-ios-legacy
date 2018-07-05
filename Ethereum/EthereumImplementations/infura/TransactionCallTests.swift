//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import EthereumImplementations
import BigInt

class TransactionCallTests: XCTestCase {

    func test_address() throws {
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
    }

}
