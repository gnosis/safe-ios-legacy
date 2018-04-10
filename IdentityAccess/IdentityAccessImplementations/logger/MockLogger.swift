//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation
import IdentityAccessDomainModel

public class MockLogger: Logger {

    public init() {}

    public func fatal(_ message: String, error: Error?, file: StaticString, line: UInt, function: StaticString) {
        print(file, function, line, message, error == nil ? "" : error!)
    }

    public func error(_ message: String, error: Error?, file: StaticString, line: UInt, function: StaticString) {
        print(file, function, line, message, error == nil ? "" : error!)
    }

    public func info(_ message: String, error: Error?, file: StaticString, line: UInt, function: StaticString) {
        print(file, function, line, message, error == nil ? "" : error!)
    }

    public func debug(_ message: String, error: Error?, file: StaticString, line: UInt, function: StaticString) {
        print(file, function, line, message, error == nil ? "" : error!)
    }

}
