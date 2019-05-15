//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class TransactionParameterViewTests: XCTestCase {

    func test_whenChangesData_thenViewChanges() {
        let view = TransactionParameterView()
        view.name = "test"
        XCTAssertEqual(view.nameLabel.text, "test")
        view.value = "test"
        XCTAssertEqual(view.valueLabel.text, "test")
    }

}
