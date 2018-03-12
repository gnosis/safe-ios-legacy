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

    func test_defaultLoggingParameters() {
        let file = #file
        let function = #function
        let logger = LoggerService(level: .debug)
        let mockLog = MockLogger()
        mockLog.detailed = true
        logger.add(mockLog)
        logger.fatal("fatal"); let line = #line
        logger.error("error")
        logger.info("info")
        logger.debug("debug")
        let expectedResult = [
            "fatal \(file) \(line) \(function)",
            "error \(file) \(line + 1) \(function)",
            "info \(file) \(line + 2) \(function)",
            "debug \(file) \(line + 3) \(function)"
        ]
        XCTAssertEqual(mockLog.loggedMessages, expectedResult.joined(separator: " "))
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

    private func detailedLogger(_ level: LogLevel) -> LoggerService {
        let logger = LoggerService(level: level)
        let mockLog = MockLogger()
        mockLog.detailed = true
        logger.add(mockLog)
        return logger
    }
}

class MockLogger: Logger {

    var detailed = false
    var loggedMessages: String { return log.joined(separator: " ") }
    private var log = [String]()

    func log(_ message: String, file: StaticString, line: UInt, function: StaticString) {
        if detailed {
            log.append("\(message) \(file) \(line) \(function)")
        } else {
            log.append(message)
        }
    }

}
