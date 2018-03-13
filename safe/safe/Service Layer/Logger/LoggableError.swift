//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

let LoggableErrorDescriptionKey = "LoggableErrorDescriptionKey"

protocol LoggableError: Error {
    func nsError(causedBy: Error?) -> NSError
}

extension LoggableError {

    func nsError(causedBy underlyingError: Error? = nil) -> NSError {
        var userInfo: [String: Any] = [NSLocalizedDescriptionKey: localizedDescription,
                                       LoggableErrorDescriptionKey: String(describing: self)]
        if let error = underlyingError {
            userInfo[NSUnderlyingErrorKey] = error
        }
        return NSError(domain: String(describing: type(of: self)),
                       code: (self as NSError).code,
                       userInfo: userInfo)
    }

}
