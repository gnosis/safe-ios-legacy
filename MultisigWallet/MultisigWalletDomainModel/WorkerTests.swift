//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel

class WorkerTests: XCTestCase {

    func test_whenCreating_thenWorksUntilStopped() {
        var counter = 0
        let exp = expectation(description: "wait")
        Worker.start(repeating: 0.1) {
            counter += 1
            if counter == 5 {
                exp.fulfill()
                return true
            }
            return false
        }
        waitForExpectations(timeout: 0.6, handler: nil)
    }

    func test_whenCreatedOnBackgroundThread_thenRunsSuccessfully() {
        let exp = expectation(description: "wait")
        DispatchQueue.global().async {
            var counter = 0
            Worker.start(repeating: 0.1) {
                if counter == 3 {
                    exp.fulfill()
                    return true
                }
                counter += 1
                return false
            }
        }
        waitForExpectations(timeout: 0.5, handler: nil)
    }

}
