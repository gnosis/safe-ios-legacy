//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit
import Common

class TransferViewTests: XCTestCase {

    let transferView = TransferView()
    let tokenData = TokenData(address: "", code: "TEST", name: "", logoURL: "", decimals: 5, balance: 123_456)

    func test_whenSettingFromAddress_thenSetsProperties() {
        XCTAssertNil(transferView.fromAddressLabel.text)
        XCTAssertEqual(transferView.fromIdenticonView.seed, "")
        transferView.fromAddress = "from_address"
        XCTAssertEqual(transferView.fromAddressLabel.address, "from_address")
        XCTAssertEqual(transferView.fromIdenticonView.seed, "from_address")
    }

    func test_whenSettingToAddress_thenSetsProperties() {
        XCTAssertNil(transferView.toAddressLabel.text)
        XCTAssertEqual(transferView.toIdenticonView.seed, "")
        transferView.toAddress = "to_address"
        XCTAssertEqual(transferView.toAddressLabel.address, "to_address")
        XCTAssertEqual(transferView.toIdenticonView.seed, "to_address")
    }

    func test_whenSettingTokenData_thenSetsProperties() {
        XCTAssertNil(transferView.amountLabel.text)
        transferView.tokenData = tokenData
        XCTAssertEqual(transferView.amountLabel.amount, tokenData)
        transferView.balanceData = tokenData
        XCTAssertEqual(transferView.balanceLabel.amount, tokenData)
    }

    func test_whenSettingNilValues_thenIgnorsIt() { // why so?
        transferView.fromAddress = "from_address"
        transferView.toAddress = "to_address"
        transferView.tokenData = tokenData
        transferView.fromAddress = nil
        transferView.toAddress = nil
        transferView.tokenData = nil
        transferView.balanceData = nil
        XCTAssertNil(transferView.fromAddressLabel.text)
        XCTAssertEqual(transferView.fromIdenticonView.seed, "")
        XCTAssertNil(transferView.toAddressLabel.text)
        XCTAssertEqual(transferView.toIdenticonView.seed, "")
        XCTAssertNil(transferView.amountLabel.text)
        XCTAssertNil(transferView.balanceLabel.text)
    }

}
