//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import EthereumDomainModel

class WorkerTests: XCTestCase {

    func test_whenTimeNonPositive_thenThrows() throws {
        XCTAssertThrowsError(try Worker(repeating: 0) { return true })
        XCTAssertThrowsError(try Worker(repeating: -1) { return true })
    }

    func test_whenRepeatingWithInterval_thenExecutesBlock() throws {
        var repeatedTimes = 0
        let repetitions = 3
        let exp = expectation(description: "wait")
        let w = try Worker(repeating: 0.1) {
            repeatedTimes += 1
            if repeatedTimes == repetitions {
                exp.fulfill()
                return true
            }
            return false
        }
        w.start()
        waitForExpectations(timeout: 0.5, handler: nil)
        XCTAssertEqual(repeatedTimes, repetitions)
    }

    func test_whenRepeatingAndReleased_thenGracefullyStops() throws {
        var counter: Int = 0
        var w: Worker? = try Worker(repeating: 0.1) {
            counter += 1
            return false
        }
        w?.start()
        _ = XCTWaiter.wait(for: [expectation(description: "nothing")], timeout: 0.5)
        w = nil
        _ = XCTWaiter.wait(for: [expectation(description: "nothing")], timeout: 0.5)
        XCTAssertNil(w)
        XCTAssertGreaterThanOrEqual(counter, 4)
    }

    func test_whenCreating_thenWorksUntilStopped() throws {
        var counter = 0
        let exp = expectation(description: "wait")
        try Worker.start(repeating: 0.1) {
            counter += 1
            if counter == 5 {
                exp.fulfill()
                return true
            }
            return false
        }
        waitForExpectations(timeout: 0.6, handler: nil)
    }

}
