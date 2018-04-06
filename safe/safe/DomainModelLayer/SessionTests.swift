//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class SessionTests: DomainTestCase {

    var session: Session!

    override func setUp() {
        super.setUp()
        session = Session(duration: 0.1)
    }

    func test_whenCreated_thenInactive() {
        XCTAssertFalse(session.isActive)
    }

    func test_start_whenCalled_thenActive() {
        session.start()
        XCTAssertTrue(session.isActive)
    }

    func test_whenExpired_thenInactive() {
        session.start()
        mockClockService.currentTime += session.duration
        XCTAssertFalse(session.isActive)
    }

}
