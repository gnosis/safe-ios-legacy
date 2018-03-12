//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class LoggerServiceTests: XCTestCase {

    let mockLog = MockLogger()
    var logger: LoggerService!

    override func setUp() {
        super.setUp()
    }

    func test_fatal_whenOffLevelIsSet_thenNothingIsLogged() {
        logger = logger(level: .off)
        mockLog.hasLogged = false
        logger.fatal("Fatal Error")
        XCTAssertFalse(mockLog.hasLogged)
    }

}

extension LoggerServiceTests {

    private func logger(level: LogLevel) -> LoggerService {
        let logger = LoggerService(level: .off)
        logger.add(mockLog)
        return logger
    }

}

class MockLogger: Logger {

    var hasLogged = false

    func log() {
        hasLogged = true
    }
}
