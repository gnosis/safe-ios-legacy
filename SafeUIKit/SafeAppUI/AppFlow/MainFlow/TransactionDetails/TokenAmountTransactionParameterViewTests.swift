//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class TokenAmountTransactionParameterViewTests: XCTestCase {

    func test_whenDataChanges_thenViewChanges() {
        let view = TokenAmountTransactionParameterView()
        view.IBStyle = TransactionValueStyle.negative.rawValue
        XCTAssertEqual(view.style, .negative)
        view.IBStyle = 100
        XCTAssertEqual(view.style, .neutral)
        XCTAssertEqual(view.IBStyle, TransactionValueStyle.neutral.rawValue)
    }

}
