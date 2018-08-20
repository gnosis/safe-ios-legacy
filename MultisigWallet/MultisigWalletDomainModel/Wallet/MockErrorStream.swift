//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel

class MockErrorStream: ErrorStream {

    private var expected_errors = [Error]()
    private var actual_errors = [Error]()

    func expect_post(_ error: Error) {
        expected_errors.append(error)
    }

    override func post(_ error: Error) {
        actual_errors.append(error)
    }

    func verify(line: UInt = #line, file: StaticString = #file) {
        XCTAssertEqual(actual_errors.map { $0.localizedDescription },
                       expected_errors.map { $0.localizedDescription },
                       file: file,
                       line: line)
    }

}
