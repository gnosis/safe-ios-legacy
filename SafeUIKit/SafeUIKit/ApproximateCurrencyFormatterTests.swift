//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit
import BigInt

class ApproximateCurrencyFormatterTests: XCTestCase {

    let approxFormatter = ApproximateCurrencyFormatter(locale: Locale(identifier: "de_DE"))

    func test_formattingFromBigInt() {
        assertFormatting(BigInt(0), 3, "")
        assertFormatting(BigInt(5), 3, "0,00")
        assertFormatting(BigInt(6), 3, "0,01")
        assertFormatting(BigInt(1_000), 3, "1,00")
        assertFormatting(BigInt(1_010), 3, "1,01")
        assertFormatting(BigInt(1_110), 3, "1,11")
        assertFormatting(BigInt(1_001), 3, "1,00")
        assertFormatting(BigInt(1_005), 3, "1,00")
        assertFormatting(BigInt(1_006), 3, "1,01")
        assertFormatting(BigInt(10_000_000_000_006), 3, "10.000.000.000,01")
        assertFormatting(BigInt(100_000_000_000_006), 3, "")
    }

    func test_formattingFromDouble() {
        assertFormatting(0, "")
        assertFormatting(0.005, "0,00")
        assertFormatting(0.006, "0,01")
        assertFormatting(1, "1,00")
        assertFormatting(1.01, "1,01")
        assertFormatting(1.11, "1,11")
        assertFormatting(1.001, "1,00")
        assertFormatting(1.005, "1,00")
        assertFormatting(1.006, "1,01")
        assertFormatting(10_000_000_000.006, "10.000.000.000,01")
        assertFormatting(100_000_000_000.006, "")
    }

    private func assertFormatting(_ value: BigInt, _ decimals: Int, _ expected: String) {
        XCTAssertEqual(approxFormatter.string(from: value, decimals: decimals), expected == "" ? "" : "≈ \(expected) €")
    }

    private func assertFormatting(_ value: Double, _ expected: String) {
        XCTAssertEqual(approxFormatter.string(from: value), expected == "" ? "" : "≈ \(expected) €")
    }

}
