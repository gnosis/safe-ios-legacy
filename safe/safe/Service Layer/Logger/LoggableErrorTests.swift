//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class LoggableErrorTests: XCTestCase {

    func test_loggableError() {
        let nsError = TestLogError.error.nsError()
        XCTAssertEqual(nsError.domain, "TestLogError")
        XCTAssertEqual(nsError.code, 0)
        XCTAssertEqual(nsError.userInfo[NSLocalizedDescriptionKey] as? String, TestLogError.error.localizedDescription)
        XCTAssertEqual(nsError.userInfo[LoggableErrorDescriptionKey] as? String, "\(TestLogError.error)")
    }

    func test_loggableErrorPreservesReason() {
        let nsError = TestLogError.error.nsError(causedBy: TestLogError.error)
        XCTAssertTrue(nsError.userInfo[NSUnderlyingErrorKey] is NSError)
        XCTAssertEqual((nsError.userInfo[NSUnderlyingErrorKey] as? NSError)?.localizedDescription,
                       TestLogError.error.localizedDescription)
    }

}
