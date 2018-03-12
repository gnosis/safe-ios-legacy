//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

protocol LoggerServiceProtocol {
    func fatal(_ message: String)
}

protocol Logger {
    func log()
}

enum LogLevel {
    case off
}

final class LoggerService: LoggerServiceProtocol {

    let level: LogLevel
    private var loggers = [Logger]()

    init(level: LogLevel) {
        self.level = level
    }

    func fatal(_ message: String) {
        if level == .off {
            return
        }
        loggers.first?.log()
    }

    func add(_ logger: Logger) {
        loggers.append(logger)
    }

}
