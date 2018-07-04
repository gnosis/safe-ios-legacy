//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import EthereumImplementations
import BigInt

class TransactionCallTests: XCTestCase {

    func test_address() throws {
        let zero: EthAddress = 0
        XCTAssertEqual(zero, 0)
        XCTAssertEqual(zero.data.count, 20)

        let lessThan20Bytes = EthAddress(BigInt(2).power(15) - 1)
        XCTAssertEqual(lessThan20Bytes.data.count, 20)

        let exactly20Bytes = EthAddress(BigInt(2).power(19) - 1)
        XCTAssertEqual(exactly20Bytes.data.count, 20)

        let moreThan20Bytes = EthAddress(BigInt(2).power(19))
        XCTAssertEqual(moreThan20Bytes.data.count, 20)

        XCTAssertEqual(exactly20Bytes, moreThan20Bytes)

        let last20Bytes = EthAddress(0b1111_1100_1111_1111_1111_1111_1111_1111_1111_1111_1100)
        let expected20BytesAddress = EthAddress(0b1100_1111_1111_1111_1111_1111_1111_1111_1111_1100)
        XCTAssertEqual(last20Bytes, expected20BytesAddress)

        let fromHex = EthAddress(hex: exactly20Bytes.hexString)
        XCTAssertEqual(fromHex, exactly20Bytes)

        let fromChecksum = EthAddress(hex: exactly20Bytes.mixedCaseChecksumEncoded)!
        XCTAssertEqual(fromChecksum, exactly20Bytes)

        struct Wrapper: Codable {
            var address: EthAddress
        }

        let wrapper = Wrapper(address: fromChecksum)
        let encoded = try JSONEncoder().encode(wrapper)
        XCTAssertTrue(String(data: encoded, encoding: .utf8)!.contains(fromChecksum.mixedCaseChecksumEncoded))

        let decoded = try JSONDecoder().decode(Wrapper.self, from: encoded)
        XCTAssertEqual(decoded.address, wrapper.address)
    }

}
