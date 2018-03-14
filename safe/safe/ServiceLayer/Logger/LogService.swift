//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

protocol LogServiceProtocol {
    func fatal(_ message: String, error: Error?, file: StaticString, line: UInt, function: StaticString)
    func error(_ message: String, error: Error?, file: StaticString, line: UInt, function: StaticString)
    func info(_ message: String, error: Error?, file: StaticString, line: UInt, function: StaticString)
    func debug(_ message: String, error: Error?, file: StaticString, line: UInt, function: StaticString)
}

protocol Logger {
    func log(_ message: String, level: LogLevel, error: Error?, file: StaticString, line: UInt, function: StaticString)
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

    private static let values: [String: LogLevel] = {
        var result = [String: LogLevel]()
        let all: [LogLevel] = [.off, .fatal, .error, .info, .debug]
        all.forEach { result[$0.string] = $0 }
        return result
    }()

    init(string: String) {
        self = LogLevel.values[string.uppercased()]  ?? .off
    }

}

/// Must be a string value. Valid values: LogLevel names
let LogServiceLogLevelKey = "SafeLogServiceLogLevelKey"
/// Must be comma-separated string of loggers. Valid loggers: crashlytics, console - case-insensitive
let LogServiceEnabledLoggersKey = "SafeLogServiceEnabledLoggersKey"
let LogServiceConsoleLoggerIdentifier = "console"
let LogServiceCrashlyticsLoggerIdentifier = "crashlytics"

protocol BundleProtocol {

    func object(forInfoDictionaryKey key: String) -> Any?

}

extension Bundle: BundleProtocol {}

final class LogService: LogServiceProtocol {

    static let shared = LogService()

    let level: LogLevel
    private (set) var loggers = [Logger]()

    init(level: LogLevel) {
        self.level = level
    }

    init(bundle: BundleProtocol = Bundle.main) {
        let string = bundle.object(forInfoDictionaryKey: LogServiceLogLevelKey) as? String ?? ""
        level = LogLevel(string: string)
        addLoggers(from: bundle)
    }

    private func addLoggers(from bundle: BundleProtocol) {
        guard let enabledLoggers = bundle.object(forInfoDictionaryKey: LogServiceEnabledLoggersKey) as? String else {
            return
        }
        let normalizedEnabledLoggers = enabledLoggers.split(separator: ",").map {
            $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if normalizedEnabledLoggers.contains(LogServiceConsoleLoggerIdentifier) {
            add(ConsoleLogger())
        }
        if normalizedEnabledLoggers.contains(LogServiceCrashlyticsLoggerIdentifier) {
            add(CrashlyticsLogger())
        }
    }

    func fatal(_ message: String,
               error: Error? = nil,
               file: StaticString = #file,
               line: UInt = #line,
               function: StaticString = #function) {
        log(.fatal, message: message, error: error, file: file, line: line, function: function)
    }

    func error(_ message: String,
               error: Error? = nil,
               file: StaticString = #file,
               line: UInt = #line,
               function: StaticString = #function) {
        log(.error, message: message, error: error, file: file, line: line, function: function)
    }

    func info(_ message: String,
              error: Error? = nil,
              file: StaticString = #file,
              line: UInt = #line,
              function: StaticString = #function) {
        log(.info, message: message, error: error, file: file, line: line, function: function)
    }

    func debug(_ message: String,
               error: Error? = nil,
               file: StaticString = #file,
               line: UInt = #line,
               function: StaticString = #function) {
        log(.debug, message: message, error: error, file: file, line: line, function: function)
    }

    private func log(_ level: LogLevel,
                     message: String,
                     error: Error?,
                     file: StaticString,
                     line: UInt,
                     function: StaticString) {
        guard self.level.rawValue >= level.rawValue else { return }
        loggers.forEach { $0.log(message, level: level, error: error, file: file, line: line, function: function) }
    }

    func add(_ logger: Logger) {
        loggers.append(logger)
    }

    func add(_ loggers: [Logger]) {
        self.loggers.append(contentsOf: loggers)
    }

}
