//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe
import IdentityAccessImplementationsTestSupport

class CountdownLabelTests: XCTestCase {

    let clock = MockClockService()
    var label = CountdownLabel()

    override func setUp() {
        super.setUp()
        label.setup(time: 0, clock: clock)
    }

    func test_whenNoClockSetup_completionCalled() {
        label = CountdownLabel()
        let expectation = self.expectation(description: "Wait")
        label.start { expectation.fulfill() }
        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func test_countdownLabelIsHiddenByDefault() {
        XCTAssertTrue(CountdownLabel().isHidden)
    }

    func test_countdownLabelShowsRemainingTime() {
        label.start {}
        clock.countdownTickBlock!(15)
        XCTAssertEqual(label.text, "00:15")
    }

    func test_whenOneDigitTime_thenPrependsZero() {
        label.start {}
        clock.countdownTickBlock!(1)
        XCTAssertEqual(label.text, "00:01")
    }

    func test_whenReachesZero_thenHides() {
        label.start {}
        clock.countdownTickBlock!(0)
        XCTAssertTrue(label.isHidden)
    }

    func test_whenDeinit_thenDoesNotCrash() {
        label.start {}
        label = CountdownLabel()
        clock.countdownTickBlock!(0)
    }

}
