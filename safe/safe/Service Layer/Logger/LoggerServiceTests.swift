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
        logger.fatal("fatal", error: TestError.error); let line = #line
        logger.error("error", error: TestError.error)
        logger.info("info")
        logger.debug("debug")
        let expectedResult = [
            "fatal \(LogLevel.fatal.string) error \(file) \(line) \(function)",
            "error \(LogLevel.error.string) error \(file) \(line + 1) \(function)",
            "info \(LogLevel.info.string) emptyError \(file) \(line + 2) \(function)",
            "debug \(LogLevel.debug.string) emptyError \(file) \(line + 3) \(function)"
        ]
        XCTAssertEqual(mockLog.loggedMessages, expectedResult.joined(separator: " "))
    }

    func test_hasSharedInstance() {
        XCTAssertNotNil(LoggerService.shared)
    }

    func test_constructorWithBundle() {
        assert(bundle: [:], .off)
        assert(bundle: [LoggerServiceLogLevelKey: ""], .off)
        assert(bundle: [LoggerServiceLogLevelKey: "fatal"], .fatal)
        assert(bundle: [LoggerServiceLogLevelKey: "Fatal"], .fatal)

        let levels: [LogLevel] = [.fatal, .error, .info, .debug]
        levels.forEach { assert(bundle: [LoggerServiceLogLevelKey: $0.string], $0) }
    }

    func test_whenBundleSpecifiesLogger_thenAddsTheLogger() {
        let validNames = "console, CraSHlytics"
        let logger = LoggerService(bundle: TestBundle(values: [LoggerServiceEnabledLoggersKey: validNames]))
        XCTAssertTrue(logger.loggers.first is ConsoleLogger)
        XCTAssertTrue(logger.loggers.last is CrashlyticsLogger)
    }

    func test_whenBundleSpecifiesInvalidLogger_thenNotAdded() {
        let invalidNameAndSeparator = "cAnsole; craSHlytics"
        let logger = LoggerService(bundle:
            TestBundle(values: [LoggerServiceEnabledLoggersKey: invalidNameAndSeparator]))
        XCTAssertTrue(logger.loggers.isEmpty)
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

    private func assert(bundle: [String: Any], _ logLevel: LogLevel) {
        let logger = LoggerService(bundle: TestBundle(values: bundle))
        XCTAssertEqual(logger.level, logLevel)
    }

}

class MockLogger: Logger {

    var detailed = false
    var loggedMessages: String { return log.joined(separator: " ") }
    private var log = [String]()

    func log(_ message: String,
             level: LogLevel,
             error: Error?,
             file: StaticString,
             line: UInt,
             function: StaticString) {
        if detailed {
            let errorStr = error != nil ? String(describing: error!) : "emptyError"
            log.append("\(message) \(level.string) \(errorStr) \(file) \(line) \(function)")
        } else {
            log.append(message)
        }
    }

}

class TestBundle: BundleProtocol {

    private let values: [String: Any]

    init(values: [String: Any]) {
        self.values = values
    }

    func object(forInfoDictionaryKey key: String) -> Any? {
        return values[key]
    }

}
