//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

protocol LoggerServiceProtocol {
    func fatal(_ message: String)
    func error(_ message: String)
    func info(_ message: String)
    func debug(_ message: String)
}

protocol Logger {
    func log(_ message: String)
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
}

final class LoggerService: LoggerServiceProtocol {

    let level: LogLevel
    private var loggers = [Logger]()

    init(level: LogLevel) {
        self.level = level
    }

    func fatal(_ message: String) {
        log(.fatal, message: message)
    }

    func error(_ message: String) {
        log(.error, message: message)
    }

    func info(_ message: String) {
        log(.info, message: message)
    }

    func debug(_ message: String) {
        log(.debug, message: message)
    }

    private func log(_ level: LogLevel, message: String) {
        guard self.level.rawValue >= level.rawValue else { return }
        loggers.forEach { $0.log(message) }
    }

    func add(_ logger: Logger) {
        loggers.append(logger)
    }

    func add(_ loggers: [Logger]) {
        self.loggers.append(contentsOf: loggers)
    }

}
