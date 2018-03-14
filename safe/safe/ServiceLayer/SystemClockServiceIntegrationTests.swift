//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class SystemClockServiceIntegrationTests: XCTestCase {

    let systemClock = SystemClockService()

    func test_whenEntropyAfterBigBangIncreases_thenSystemTimeAdvances() {
        let before = systemClock.currentTime
        increaseEntropy()
        let after = systemClock.currentTime
        XCTAssertTrue(before < after)
    }

    private func increaseEntropy() {
        wait()
    }

}
