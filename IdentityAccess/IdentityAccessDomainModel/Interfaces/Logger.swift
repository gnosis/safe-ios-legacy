//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

public protocol Logger {
    func fatal(_ message: String, error: Error?, file: StaticString, line: UInt, function: StaticString)
    func error(_ message: String, error: Error?, file: StaticString, line: UInt, function: StaticString)
    func info(_ message: String, error: Error?, file: StaticString, line: UInt, function: StaticString)
    func debug(_ message: String, error: Error?, file: StaticString, line: UInt, function: StaticString)
}
