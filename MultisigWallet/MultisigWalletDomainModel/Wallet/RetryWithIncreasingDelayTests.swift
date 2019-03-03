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
            callCount = $0
        }
        try retry.start()
        XCTAssertEqual(callCount, 0)
    }

    func test_whenThrows_thenRetriesAgainUntilMaxAttempts() throws {
        var callCount = 0
        let retry = RetryWithIncreasingDelay(maxAttempts: 3) {
            callCount = $0
            throw TestError.error
        }
        XCTAssertThrowsError(try retry.start())
        XCTAssertEqual(callCount, 2)
    }

    func test_whenFinished_thenReturnsValue() throws {
        let retry = RetryWithIncreasingDelay(maxAttempts: 1) { true }
        XCTAssertTrue(try retry.start())
    }

    func test_whenDelaySpecified_thenDelaysExecution() throws {
        let delay = 0.2
        let retry = RetryWithIncreasingDelay(maxAttempts: 2, startDelay: delay) { attempt in
            if attempt < 1 {
                throw TestError.error
            }
        }
        let now = Date()
        XCTAssertNoThrow(try retry.start())
        XCTAssertGreaterThanOrEqual(Date().timeIntervalSince(now), delay)
    }

}
