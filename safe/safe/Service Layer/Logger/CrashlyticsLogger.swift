//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation
import Crashlytics

protocol CrashlyticsProtocol {
    func recordError(_ error: Error)
}

let LoggableErrorDescriptionKey = "LoggableErrorDescriptionKey"

protocol LoggableError: Error {
    var rawValue: Int { get }
    func nsError() -> NSError
}

extension LoggableError {

    func nsError() -> NSError {
        return NSError(domain: String(describing: type(of: self)),
                       code: rawValue,
                       userInfo: [NSLocalizedDescriptionKey: localizedDescription,
                                  LoggableErrorDescriptionKey: String(describing: self)])
    }

}

final class CrashlyticsLogger: Logger {

    private let crashlytics: CrashlyticsProtocol

    init(crashlytics: CrashlyticsProtocol = Crashlytics.sharedInstance()) {
        self.crashlytics = crashlytics
    }

    func log(_ message: String,
             level: LogLevel,
             error: Error?,
             file: StaticString,
             line: UInt,
             function: StaticString) {
        guard let error = error as NSError? else { return }
        var userInfo = error.userInfo
        userInfo["message"] = message
        crashlytics.recordError(NSError(domain: error.domain, code: error.code, userInfo: userInfo))
    }

}

extension Crashlytics: CrashlyticsProtocol {}
