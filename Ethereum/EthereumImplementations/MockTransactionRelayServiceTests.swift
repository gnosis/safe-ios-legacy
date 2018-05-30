//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import EthereumImplementations

class MockTransactionRelayServiceTests: XCTestCase {

    func test_random() {
        let avg = 1.0
        let dev = 0.5
        for _ in (0..<1_000) {
            let value = MockTransactionRelayService.random(average: avg, maxDeviation: dev)
            XCTAssertLessThanOrEqual(value, avg + dev)
            XCTAssertGreaterThanOrEqual(value, avg - dev)
        }
    }

}
