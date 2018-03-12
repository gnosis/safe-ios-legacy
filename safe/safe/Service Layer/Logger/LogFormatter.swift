//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

/**
 %l - Log Level
 %f - Filename
 %n - Line in file
 %m - Method name
 %s - Message
 %t - Timestamp
 */
final class LogFormatter {

    static let defaultDateFormat = "yyyy-MM-dd hh:mm:ss.SSSSSS"
    static let defaultMessageFormat = "%t [%l] %f:%n %m: %s\n"

    var dateFormat = defaultDateFormat
    var format = defaultMessageFormat

    func string(from message: String,
                logLevel: LogLevel? = nil,
                filename: String? = nil,
                method: String? = nil,
                line: UInt? = nil,
                timestamp: Date? = nil) -> String {
        var result = format
        if let logLevel = logLevel {
            result = result.replacingOccurrences(of: "%l", with: logLevel.string)
        }
        if let filename = filename {
            result = result.replacingOccurrences(of: "%f", with: filename)
        }
        if let method = method {
            result = result.replacingOccurrences(of: "%m", with: method)
        }
        if let line = line {
            result = result.replacingOccurrences(of: "%n", with: String(describing: line))
        }

        return result.replacingOccurrences(of: "%s", with: message)
    }

}
