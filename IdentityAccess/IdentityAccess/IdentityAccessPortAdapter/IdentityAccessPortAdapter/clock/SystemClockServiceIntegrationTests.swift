//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import IdentityAccessPortAdapter
import IdentityAccessDomainModel
import CommonTestSupport

class SystemClockServiceIntegrationTests: XCTestCase {

    let systemClock = SystemClockService()

    func test_whenEntropyAfterBigBangIncreases_thenSystemTimeAdvances() {
        let before = systemClock.currentTime
        increaseEntropy()
        let after = systemClock.currentTime
        XCTAssertTrue(before < after)
    }

    private func increaseEntropy() {
        delay()
    }

    func test_countdownTimer() {
        let maxTime: TimeInterval = 3
        var timeLeft: TimeInterval = maxTime
        let exp = expectation(description: "Timer")
        systemClock.countdown(from: maxTime) { remainingSeconds in
            XCTAssertEqual(remainingSeconds, timeLeft)
            timeLeft -= 1
            if remainingSeconds == 0 {
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: maxTime + 1, handler: nil)
    }

}
