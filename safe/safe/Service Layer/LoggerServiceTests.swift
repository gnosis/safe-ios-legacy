//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class LoggerServiceTests: XCTestCase {

    func test_logLevels() {
        assert(.off, allowsOnly: "")
        assert(.fatal, allowsOnly: "fatal")
        assert(.error, allowsOnly: "fatal error")
        assert(.info, allowsOnly: "fatal error info")
        assert(.debug, allowsOnly: "fatal error info debug")
    }

    func test_whenLoggerServiceCalled_thenAllLoggersAreTriggered() {
        let logger = LoggerService(level: .error)
        let mockLog1 = MockLogger()
        let mockLog2 = MockLogger()
        logger.add([mockLog1, mockLog2])
        logger.error("error")
        XCTAssertEqual(mockLog1.loggedMessages, "error")
        XCTAssertEqual(mockLog2.loggedMessages, "error")
    }

}

extension LoggerServiceTests {

    private func assert(_ level: LogLevel, allowsOnly expectedLog: String) {
        let logger = LoggerService(level: level)
        let mockLog = MockLogger()
        logger.add(mockLog)
        logger.fatal("fatal")
        logger.error("error")
        logger.info("info")
        logger.debug("debug")
        XCTAssertEqual(mockLog.loggedMessages, expectedLog)
    }
}

class MockLogger: Logger {

    var loggedMessages: String { return log.joined(separator: " ") }
    private var log = [String]()

    func log(_ message: String) {
        log.append(message)
    }

}
