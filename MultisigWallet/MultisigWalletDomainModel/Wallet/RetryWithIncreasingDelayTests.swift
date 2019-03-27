//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel
import CommonTestSupport
import Common

class RetryWithIncreasingDelayTests: XCTestCase {

    func test_whenSuccess_thenReturns() throws {
        var callCount = 0
        let retry = RetryWithIncreasingDelay(maxAttempts: 3) {
            callCount += 1
        }
        try retry.start()
        XCTAssertEqual(callCount, 1)
    }

    func test_whenThrows_thenRetriesAgainUntilMaxAttempts() throws {
        var callCount = 0
        let retry = RetryWithIncreasingDelay(maxAttempts: 3) {
            callCount += 1
            throw TestError.error
        }
        XCTAssertThrowsError(try retry.start())
        XCTAssertEqual(callCount, 3)
    }

    func test_whenFinished_thenReturnsValue() throws {
        let retry = RetryWithIncreasingDelay(maxAttempts: 1) { true }
        XCTAssertTrue(try retry.start())
    }

    func test_whenDelaySpecified_thenDelaysExecution() throws {
        let attempts = 2
        let delay = 0.2
        var callCount = 0
        let retry = RetryWithIncreasingDelay(maxAttempts: attempts, startDelay: delay) {
            callCount += 1
            if callCount < attempts {
                throw TestError.error
            }

        }
        let now = Date()
        XCTAssertNoThrow(try retry.start())
        XCTAssertGreaterThanOrEqual(Date().timeIntervalSince(now), delay)
        XCTAssertEqual(callCount, attempts)
    }

}
