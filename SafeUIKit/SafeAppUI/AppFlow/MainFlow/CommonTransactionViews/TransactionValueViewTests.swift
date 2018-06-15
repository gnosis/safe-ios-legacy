//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class TransactionValueViewTests: XCTestCase {

    func test_whenDataChanges_thenViewChanges() {
        let view = TransactionValueView()
        view.tokenAmount = "test"
        XCTAssertEqual(view.tokenLabel.text, "test")
        view.fiatAmount = "test"
        XCTAssertEqual(view.fiatLabel.text, "test")
        view.IBStyle = TransactionValueStyle.negative.rawValue
        XCTAssertEqual(view.style, .negative)
        view.isSingleValue = true
        XCTAssertTrue(view.fiatLabel.isHidden)
        view.style = .neutral
        XCTAssertEqual(view.IBStyle, TransactionValueStyle.neutral.rawValue)
        view.style = .positive
        view.IBStyle = -10
        XCTAssertEqual(view.IBStyle, TransactionValueStyle.neutral.rawValue)
    }

}
