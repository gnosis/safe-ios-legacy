//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import Source
import Expected
import Actual

class SourceTests: XCTestCase {

    func test_hello() {
        XCTAssertEqual(Actual.hello(), Expected.hello())
        greet()
//            bye() // disabled until homebrew Sourcery supports it
    }
}
