//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit
import Common
import BigInt

class AmountLabelTests: XCTestCase {

    let label = AmountLabel()

    func test_settingAmount() {
        XCTAssertNil(label.text)
        label.amount = TokenData.Ether.withBalance(BigInt(1e18) + BigInt(1e14))
        XCTAssertEqual(label.text, label.formatter.string(from: label.amount!.balance!))
        let nilBalance = TokenData(address: "0", code: "A", name: "a", logoURL: "", decimals: 18, balance: nil)
        label.amount = nilBalance
        XCTAssertEqual(label.text, label.formatter.string(from: 0))
        label.amount = nil
        XCTAssertNil(label.text)
    }

}
