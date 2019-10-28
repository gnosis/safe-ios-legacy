//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit

class EthereumAddressLabelTests: XCTestCase {

    let label = EthereumAddressLabel()

    func test_address() {
        XCTAssertNil(label.text)
        label.address = "1"
        XCTAssertEqual(label.text, label.formatter.string(from: "1"))
        label.suffix = "hi"
        XCTAssertEqual(label.text, label.formatter.string(from: "1")! + " " + "hi")
        label.address = nil
        XCTAssertNil(label.text)
    }

    func test_formatting() {
        label.address = "1"
        label.suffix = "suffix"
        label.name = nil
        XCTAssertEqual(label.text, label.formatter.string(from: "1")! + " " + "suffix")

        label.address = "1"
        label.suffix = nil
        label.name = nil
        XCTAssertEqual(label.text, label.formatter.string(from: "1")!)

        label.name = "name"
        label.address = "1"
        label.suffix = "suffix"
        XCTAssertEqual(label.text, "name" + " " + "suffix" + "\n" + label.withNameFormatter.string(from: "1")!)

        label.name = "name"
        label.address = "1"
        label.suffix = nil
        XCTAssertEqual(label.text, "name" + "\n" + label.withNameFormatter.string(from: "1")!)
    }

}
