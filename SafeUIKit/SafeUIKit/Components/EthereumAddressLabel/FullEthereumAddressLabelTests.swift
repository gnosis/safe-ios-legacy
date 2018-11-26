//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit

class FullEthereumAddressLabelTests: XCTestCase {

    let label = FullEthereumAddressLabel()

    func test_address() {
        XCTAssertNil(label.attributedText)
        label.address = "1"
        XCTAssertEqual(label.attributedText, label.formatter.attributedString(from: "1"))
        label.address = nil
        XCTAssertNil(label.attributedText)
    }

}
