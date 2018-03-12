//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

protocol LoggerServiceProtocol {
    func fatal(_ message: String, file: StaticString, line: UInt, function: StaticString)
    func error(_ message: String, file: StaticString, line: UInt, function: StaticString)
    func info(_ message: String, file: StaticString, line: UInt, function: StaticString)
    func debug(_ message: String, file: StaticString, line: UInt, function: StaticString)
}

protocol Logger {
    func log(_ message: String, file: StaticString, line: UInt, function: StaticString)
}

/**
 FATAL: Designates very severe error events that will presumably lead the application to abort.

 ERROR: Designates error events that might still allow the application to continue running.

 INFO: Designates informational messages that highlight the progress of the application at coarse-grained level.

 DEBUG: Designates fine-grained informational events that are most useful to debug an application.
 */
enum LogLevel: Int {
    case off
    case fatal
    case error
    case info
    case debug

    var string: String {
        switch self {
        case .off: return "OFF"
        case .fatal: return "FATAL"
        case .error: return "ERROR"
        case .info: return "INFO"
        case .debug: return "DEBUG"
        }
    }

}

final class LoggerService: LoggerServiceProtocol {

    let level: LogLevel
    private var loggers = [Logger]()

    init(level: LogLevel) {
        self.level = level
    }

    func fatal(_ message: String,
               file: StaticString = #file,
               line: UInt = #line,
               function: StaticString = #function) {
        log(.fatal, message: message, file: file, line: line, function: function)
    }

    func error(_ message: String,
               file: StaticString = #file,
               line: UInt = #line,
               function: StaticString = #function) {
        log(.error, message: message, file: file, line: line, function: function)
    }

    func info(_ message: String,
              file: StaticString = #file,
              line: UInt = #line,
              function: StaticString = #function) {
        log(.info, message: message, file: file, line: line, function: function)
    }

    func debug(_ message: String,
               file: StaticString = #file,
               line: UInt = #line,
               function: StaticString = #function) {
        log(.debug, message: message, file: file, line: line, function: function)
    }

    private func log(_ level: LogLevel,
                     message: String,
                     file: StaticString,
                     line: UInt,
                     function: StaticString) {
        guard self.level.rawValue >= level.rawValue else { return }
        loggers.forEach { $0.log(message, file: file, line: line, function: function) }
    }

    func add(_ logger: Logger) {
        loggers.append(logger)
    }

    func add(_ loggers: [Logger]) {
        self.loggers.append(contentsOf: loggers)
    }

}
