//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit
import BigInt
import Common

class TokenFormatterTests: XCTestCase {

    let f = TokenFormatter()

    // swiftlint:disable number_separator
    func test_stringFromNumber() {
        // full format
        XCTAssertEqual(f.string(from: BigDecimal(1_000, 0), shortFormat: false), "1,000")
        XCTAssertEqual(f.string(from: BigDecimal(1_000, 1), shortFormat: false), "100")
        XCTAssertEqual(f.string(from: BigDecimal(1_000, 3), shortFormat: false), "1")
        XCTAssertEqual(f.string(from: BigDecimal(1_000, 7), shortFormat: false), "0.0001")

        // 0.12345600 -> 0.12345
        XCTAssertEqual(f.string(from: BigDecimal(0_123456000, 9)), "0.12345")
        // 1.123456000 -> 1.12345
        XCTAssertEqual(f.string(from: BigDecimal(1_123456000, 9)), "1.12345")
        // 100.123456000 -> 100.12345
        XCTAssertEqual(f.string(from: BigDecimal(100_123456000, 9)), "100.12345")
        // 999.123456000 -> 999.12345
        XCTAssertEqual(f.string(from: BigDecimal(999_123456000, 9)), "999.12345")
        // 999.999999999 -> 999.99999
        XCTAssertEqual(f.string(from: BigDecimal(999_999999999, 9)), "999.99999")
        // 1,000.0001
        XCTAssertEqual(f.string(from: BigDecimal(1000_000123456, 9)), "1,000.0001")
        // 9,999.9999
        XCTAssertEqual(f.string(from: BigDecimal(9_999_999999999, 9)), "9,999.9999")
        // 10,000.001
        XCTAssertEqual(f.string(from: BigDecimal(10_000_001000000, 9)), "10,000.001")
        // 99,999.999
        XCTAssertEqual(f.string(from: BigDecimal(99_999_999456789, 9)), "99,999.999")
        // 100,000.01
        XCTAssertEqual(f.string(from: BigDecimal(100_000_010000000, 9)), "100,000.01")
        // 999,999.99
        XCTAssertEqual(f.string(from: BigDecimal(999_999_999999999, 9)), "999,999.99")
        // 1,000,000.1
        XCTAssertEqual(f.string(from: BigDecimal(1_000_000_100000000, 9)), "1,000,000.1")
        // 9,999,999.9
        XCTAssertEqual(f.string(from: BigDecimal(9_999_999_999999999, 9)), "9,999,999.9")
        // 10,000,000
        XCTAssertEqual(f.string(from: BigDecimal(10_000_000_000000000, 9)), "10,000,000")
        // 99,999,999
        XCTAssertEqual(f.string(from: BigDecimal(99_999_999_999999999, 9)), "99,999,999")
        // 100.001M
        XCTAssertEqual(f.string(from: BigDecimal(100_000_000_000000000, 9)), "100M")
        XCTAssertEqual(f.string(from: BigDecimal(100_001_000_000000000, 9)), "100.001M")
        // 999.999M
        XCTAssertEqual(f.string(from: BigDecimal(999_999_999_000000000, 9)), "999.999M")
        // 1.001B
        XCTAssertEqual(f.string(from: BigDecimal(1_000_000_000_000000000, 9)), "1B")
        XCTAssertEqual(f.string(from: BigDecimal(1_001_000_000_000000000, 9)), "1.001B")
        // 999.999B - 999_999_999_000_000000000
        XCTAssertEqual(f.string(from: BigDecimal(BigInt("999999999000000000000"), 9)), "999.999B")
        // 1.001T - 1_001_000_000_000_000000000
        XCTAssertEqual(f.string(from: BigDecimal(BigInt("1000000000000000000000"), 9)), "1T")
        XCTAssertEqual(f.string(from: BigDecimal(BigInt("1001000000000000000000"), 9)), "1.001T")
        // 999.999T - 999_999_999_000_000_000000000
        XCTAssertEqual(f.string(from: BigDecimal(BigInt("999999999000000000000000"), 9)), "999.999T")
        // > 999T - 1_000_000_000_000_000_000000000
        XCTAssertEqual(f.string(from: BigDecimal(BigInt("1000000000000000000000000"), 9)), "> 999T")
        // Negatives
        XCTAssertEqual(f.string(from: BigDecimal(BigInt("-1000000000000000000000000"), 9)), "< -999T")
        XCTAssertEqual(f.string(from: BigDecimal(BigInt("-999999999000000000000000"), 9)), "-999.999T")
        XCTAssertEqual(f.string(from: BigDecimal(-10_000_001000000, 9)), "-10,000.001")
        XCTAssertEqual(f.string(from: BigDecimal(0, 9)), "0")
        XCTAssertEqual(f.string(from: BigDecimal(0_000000001, 9)), "0")
        XCTAssertEqual(f.string(from: BigDecimal(-0_000000001, 9)), "0")
        // Plus sign
        XCTAssertEqual(f.string(from: BigDecimal(1, 0), forcePlusSign: true), "+1")
        XCTAssertEqual(f.string(from: BigDecimal(BigInt("1000000000000000000000000"), 9), forcePlusSign: true),
                       "> +999T")

        // TokenData
        let oneEth = BigInt(10).power(18)
        XCTAssertEqual(f.string(from: TokenData.Ether.withBalance(oneEth)), "1 ETH")

        let noCode = TokenData(address: "", code: "", name: "", logoURL: "", decimals: 18, balance: oneEth)
        XCTAssertEqual(f.string(from: noCode), "1")

        let noAmount = TokenData(address: "", code: "ETH", name: "", logoURL: "", decimals: 18, balance: nil)
        XCTAssertEqual(f.string(from: noAmount), "-")

        // roundUp
        f.roundingBehavior = .roundUp

        XCTAssertEqual(f.string(from: BigDecimal(0_011, 3)), "0.011")
        XCTAssertEqual(f.string(from: BigDecimal(0_00001, 5)), "0.00001")
        XCTAssertEqual(f.string(from: BigDecimal(0_0000101, 7)), "0.00002")
        XCTAssertEqual(f.string(from: BigDecimal(0_0000901, 7)), "0.0001")
        XCTAssertEqual(f.string(from: BigDecimal(0_9999901, 7)), "1")
        XCTAssertEqual(f.string(from: BigDecimal(100_001_000_000000001, 9)), "100.002M")
        XCTAssertEqual(f.string(from: BigDecimal(0_00060_2600000301300, 18)), "0.00061")
    }

    func test_NumberFromString() {
        let precision = 3
        XCTAssertEqual(f.number(from: "0", precision: precision), BigDecimal(0, precision))
        XCTAssertEqual(f.number(from: "1", precision: precision), BigDecimal(1000, precision))
        XCTAssertEqual(f.number(from: "0,1", precision: precision), BigDecimal(100, precision))
        XCTAssertEqual(f.number(from: "0,0001", precision: precision), BigDecimal(0, precision))
        XCTAssertEqual(f.number(from: "0,001", precision: precision), BigDecimal(1, precision))
        XCTAssertEqual(f.number(from: "0,1000000", precision: precision), BigDecimal(100, precision))
        XCTAssertEqual(f.number(from: "0001,1", precision: precision), BigDecimal(1_100, precision))
        XCTAssertEqual(f.number(from: "-1", precision: precision), BigDecimal(-1_000, precision))
        XCTAssertEqual(f.number(from: "-0", precision: precision), BigDecimal(0, precision))
        XCTAssertEqual(f.number(from: "1.000,01", precision: 3), BigDecimal(1000010, precision))
    }
}
