//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import BigInt

class TokenNumberFormatterTests: XCTestCase {

    let formatter = TokenNumberFormatter()

    func test_stringFromNumber() {
        formatter.decimals = 18
        assert(number: 0, equalTo: "0")
        assert(number: 1, equalTo: "0,000000000000000001")
        assert(number: BigInt(10).power(18), equalTo: "1")
        assert(number: BigInt(10).power(18) + BigInt(10).power(17), equalTo: "1,1")
        assert(number: BigInt(10).power(18) + 1, equalTo: "1,000000000000000001")
        assert(number: -1, equalTo: "-0,000000000000000001")
        assert(number: -0, equalTo: "0")
    }

    func test_numberFromString() {
        formatter.decimals = 3
        assert(string: "0", equalTo: 0)
        assert(string: "1", equalTo: 1_000)
        assert(string: "0,1", equalTo: 100)
        assert(string: "0,0001", equalTo: 0)
        assert(string: "0,001", equalTo: 1)
        assert(string: "0,1000000", equalTo: 100)
        assert(string: "0001,1", equalTo: 1_100)
        assert(string: "1 000", equalTo: 1_000_000)
        assert(string: "-1", equalTo: -1_000)
        assert(string: "-0", equalTo: 0)
    }

    private func assert(string: String, equalTo number: BigInt, line: UInt = #line) {
        XCTAssertEqual(formatter.number(from: string), number, line: line)
    }

    private func assert(number: BigInt, equalTo string: String, line: UInt = #line) {
        XCTAssertEqual(formatter.string(from: number), string, line: line)
    }

    func test_groupingSeparator() {
        formatter.usesGroupingSeparator = true
        assert(number: 1_000, equalTo: "1 000")
        assert(number: 1_000_000, equalTo: "1 000 000")
        assert(number: 100, equalTo: "100")

        formatter.usesGroupingSeparatorForFractionDigits = true
        formatter.decimals = 6
        assert(number: 1, equalTo: "0,000 001")
        assert(number: 1_000, equalTo: "0,001")
    }

    func test_tokenSymbol() {
        formatter.tokenSymbol = "$"
        assert(number: 1, equalTo: "1 $")

        formatter.tokenCode = "ETH"
        assert(number: 1, equalTo: "1 $")

        formatter.tokenSymbol = nil
        assert(number: 1, equalTo: "1 ETH")
    }
}
