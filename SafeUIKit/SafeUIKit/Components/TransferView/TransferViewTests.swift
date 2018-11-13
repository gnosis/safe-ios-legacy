//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit

class TransferViewTests: XCTestCase {

    let transferView = TransferView()

    func test_whenSettingFromAddress_thenSetsProperties() {
        XCTAssertEqual(transferView.fromAddressLabel.text, "")
        XCTAssertEqual(transferView.fromIdenticonView.seed, "")
        transferView.fromAddress = "from_address"
        XCTAssertEqual(transferView.fromAddressLabel.text, "from_address")
        XCTAssertEqual(transferView.fromIdenticonView.seed, "from_address")
    }

    func test_whenSettingToAddress_thenSetsProperties() {
        XCTAssertEqual(transferView.toAddressLabel.text, "")
        XCTAssertEqual(transferView.toIdenticonView.seed, "")
        transferView.fromAddress = "to_address"
        XCTAssertEqual(transferView.toAddressLabel.text, "to_address")
        XCTAssertEqual(transferView.toIdenticonView.seed, "to_address")
    }

}
