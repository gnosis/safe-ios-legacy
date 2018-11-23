//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit
import BigInt
import EthereumKit

class EthereumAddressFormatterTests: XCTestCase {

    let formatter = EthereumAddressFormatter()
    let allZero = Data(repeating: 0, count: 20)
    let allDigits = Data([1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0])
    let fewBytes = Data([1])
    let manyBytes = Data(repeating: 0, count: 21)
    let allChars = Data([0xaa, 0xbb, 0xcc, 0xdd, 0xee, 0xff, 0xaa, 0xbb, 0xcc, 0xdd, 0xee, 0xff,
                         0xaa, 0xbb, 0xcc, 0xdd, 0xee, 0xff, 0xaa, 0xbb])

    func test_paddingAndTruncatingBytes() {
        XCTAssertEqual(formatter.string(from: allZero), "0x0000000000000000000000000000000000000000")
        XCTAssertEqual(formatter.string(from: allDigits), "0x0102030405060708090001020304050607080900")
        XCTAssertEqual(formatter.string(from: fewBytes), "0x0000000000000000000000000000000000000001")
        XCTAssertEqual(formatter.string(from: manyBytes), "0x0000000000000000000000000000000000000000")
    }

    func test_hexMode() {
        formatter.hexMode = .lowercased
        XCTAssertEqual(formatter.string(from: allChars), "0xaabbccddeeffaabbccddeeffaabbccddeeffaabb")
        formatter.hexMode = .uppercased
        XCTAssertEqual(formatter.string(from: allChars), "0xAABBCCDDEEFFAABBCCDDEEFFAABBCCDDEEFFAABB")
        formatter.hexMode = .mixedCased
        assertHex("0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed")
        assertHex("0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359")
        assertHex("0xdbF03B407c01E7cD3CBea99509d93f8DDDC8C6FB")
        assertHex("0xD1220A0cf47c7B9Be7A2E6BA89F429762e7b9aDb")
    }

    func test_truncationMode() {
        formatter.truncationMode = .head
        formatter.maximumAddressLength = 39
        XCTAssertEqual(formatter.string(from: allZero), "0x…00000000000000000000000000000000000000")
        formatter.truncationMode = .tail
        XCTAssertEqual(formatter.string(from: allZero), "0x00000000000000000000000000000000000000…")
        formatter.truncationMode = .middle
        XCTAssertEqual(formatter.string(from: allZero), "0x0000000000000000000…0000000000000000000")
        formatter.usesHeadTailSplit = true
        formatter.headLength = 2
        formatter.tailLength = 4
        XCTAssertEqual(formatter.string(from: allZero), "0x00…0000")
        formatter.usesHexPrefix = false
        XCTAssertEqual(formatter.string (from: allZero), "00…0000")
    }

    func test_attributedString() {
        formatter.bodyAttributes = [.foregroundColor: UIColor.white]
        formatter.headAttributes = [.foregroundColor: UIColor.red]
        formatter.tailAttributes = [.foregroundColor: UIColor.black]
        let string = NSMutableAttributedString(string: "0x0000000000000000000000000000000000000000",
                                               attributes: formatter.bodyAttributes)
        string.addAttributes(formatter.headAttributes!,
                             range: NSRange(location: 0,
                                            length: formatter.hexPrefixLength + formatter.headLength))
        string.addAttributes(formatter.tailAttributes!,
                             range: NSRange(location: string.length - formatter.tailLength,
                                            length: formatter.tailLength))
        XCTAssertEqual(formatter.attributedString(from: allZero), string)
    }

    func test_fromString() {
        XCTAssertEqual(formatter.string(from: "0x1"), "0x0000000000000000000000000000000000000001")
        XCTAssertEqual(formatter.attributedString(from: "0x1"),
                       NSMutableAttributedString(string: "0x0000000000000000000000000000000000000001"))
    }

    private func assertHex(_ value: String, line: UInt = #line) {
        XCTAssertEqual(formatter.string(from: Data(hex: value)), value, line: line)
    }

}
