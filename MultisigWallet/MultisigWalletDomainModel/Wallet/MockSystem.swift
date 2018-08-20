//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel

class MockSystem: System {

    private var expected_exit = [Int32]()
    private var actual_exit = [Int32]()

    func expect_exit(_ status: Int32) {
        expected_exit.append(status)
    }

    override func exit(_ status: Int32) {
        actual_exit.append(status)
    }

    func verify(line: UInt = #line, file: StaticString = #file) {
        XCTAssertEqual(actual_exit, expected_exit, file: file, line: line)
    }

}
