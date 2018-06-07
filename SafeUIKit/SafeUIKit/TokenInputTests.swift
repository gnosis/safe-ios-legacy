//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit

class TokenInputTests: XCTestCase {

    var tokenInput: TokenInput!

    override func setUp() {
        super.setUp()
        tokenInput = TokenInput()
    }

    func test_whenCreated_thenAllElementsAreThere() {
        XCTAssertNotNil(tokenInput.integerPartTextField)
        XCTAssertNotNil(tokenInput.fractionalPartTextField)
    }

}
