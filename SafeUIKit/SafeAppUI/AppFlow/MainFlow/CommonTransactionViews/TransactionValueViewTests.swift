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
        XCTAssertEqual(view.style, .positive)
        view.isSingleValue = true
        XCTAssertTrue(view.fiatLabel.isHidden)
    }

}
