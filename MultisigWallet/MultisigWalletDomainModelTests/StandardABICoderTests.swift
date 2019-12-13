//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel

class StandardABICoderTests: XCTestCase {

    func test_uint8() throws {
        assertEqual(0x00, hex: "00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00")
        assertEqual(0x01, hex: "00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01")
        assertEqual(0xAB, hex: "00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 AB")
        assertEqual(0xFF, hex: "00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF")
    }

    private func assertEqual(_ lhs: SOLUInt8, hex rhs: String, line: UInt = #line) {
        XCTAssertNoThrow(try {
            let actual: Data = try StandardABIEncoder().encode(lhs)
            let expected = Data(hexString: rhs)
            XCTAssertEqual(actual, expected, "\(actual.hexString) != \(expected.hexString)", line: line)
        }())
    }
}

fileprivate extension Data {

    init(hexString: String) {
        self.init(hex: hexString.replacingOccurrences(of: " ", with: ""))
    }

    var hexString: String {
        self.map { String(format: "%02X", $0) }.joined(separator: " ")
    }

}
