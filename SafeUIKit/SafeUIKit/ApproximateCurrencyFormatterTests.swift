//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit
import BigInt

class ApproximateCurrencyFormatterTests: XCTestCase {

    let approxFormatter = ApproximateCurrencyFormatter(locale: Locale(identifier: "de_DE"))

    func test_formatting() {
        assertFormatting(BigInt(0), 3, "0,00")
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

    private func assertFormatting(_ value: BigInt, _ decimals: Int, _ expected: String) {
        XCTAssertEqual(approxFormatter.string(from: value, decimals: decimals), expected == "" ? "" : "≈ \(expected) €")
    }

}
