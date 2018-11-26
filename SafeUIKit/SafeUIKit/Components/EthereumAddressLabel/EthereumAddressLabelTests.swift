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

}
