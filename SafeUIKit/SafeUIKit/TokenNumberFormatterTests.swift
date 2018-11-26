//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit
import BigInt

class TokenNumberFormatterTests: XCTestCase {

    let formatter = TokenNumberFormatter()

    override func setUp() {
        super.setUp()
        formatter.locale = Locale(identifier: "de_DE")
    }

    func test_stringFromNumber() {
        assert(number: 0, equalTo: "0,00")
        assert(number: 1, equalTo: "0,000000000000000001")
        assert(number: BigInt(10).power(18), equalTo: "1,00")
        assert(number: BigInt(10).power(18) + BigInt(10).power(17), equalTo: "1,10")
        assert(number: BigInt(10).power(18) + 1, equalTo: "1,000000000000000001")
        assert(number: -1, equalTo: "- 0,000000000000000001")
        assert(number: -0, equalTo: "0,00")
    }

    func test_displayedDecimals() {
        formatter.displayedDecimals = 4
        assert(number: 0, equalTo: "0,00")
        assert(number: 1, equalTo: "0,000~")
        assert(number: BigInt(10e17), equalTo: "1,00")
        assert(number: BigInt(10e17) + BigInt(10e16), equalTo: "1,10")
        assert(number: BigInt(10e17) + 1, equalTo: "1,000~")
        assert(number: -1, equalTo: "- 0,000~")
        assert(number: -0, equalTo: "0,00")
        assert(number: BigInt(10e17) + BigInt(10e13) + 9 * BigInt(10e12), equalTo: "1,000~")
        assert(number: BigInt(10e17) + BigInt(10e14), equalTo: "1,001")
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
        assert(string: "1.000", equalTo: 1_000_000)
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
        formatter.decimals = 0
        assert(number: 1_000, equalTo: "1.000,00")
        assert(number: 1_000_000, equalTo: "1.000.000,00")
        assert(number: 100, equalTo: "100,00")

        formatter.usesGroupingSeparatorForFractionDigits = true
        formatter.decimals = 6
        assert(number: 1, equalTo: "0,000.001")
        assert(number: 1_000, equalTo: "0,001")
    }

    func test_tokenSymbol() {
        formatter.tokenSymbol = "$"
        formatter.decimals = 0
        assert(number: 1, equalTo: "1,00 $")

        formatter.tokenCode = "ETH"
        assert(number: 1, equalTo: "1,00 $")

        formatter.tokenSymbol = nil
        assert(number: 1, equalTo: "1,00 ETH")
    }

    func test_whenZero_thenPointIsLocaleSpecific() {
        formatter.locale = Locale(identifier: "en_US")
        assert(number: 0, equalTo: "0.00")
    }

}
