//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class SessionTests: XCTestCase {

    var session = Session(duration: 0.1)

    func test_whenCreated_thenInactive() {
        XCTAssertFalse(session.isActive)
    }

}
