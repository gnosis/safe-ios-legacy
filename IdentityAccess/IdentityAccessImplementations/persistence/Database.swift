//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public protocol Database {

    func create() throws
    func destroy() throws
    func connection() throws -> Connection
    func close(_ connection: Connection) throws

}

public protocol Connection {

    func prepare(statement: String) throws -> Statement
    func lastErrorMessage() -> String?

}

public protocol Statement {

    func set(_ value: String, at index: Int) throws
    func set(_ value: Int, at index: Int) throws
    func set(_ value: Double, at index: Int) throws
    func setNil(at index: Int) throws

    func set(_ value: String, forKey key: String) throws
    func set(_ value: Int, forKey key: String) throws
    func set(_ value: Double, forKey key: String) throws
    func setNil(forKey key: String) throws

    @discardableResult
    func execute() throws -> ResultSet?

}

public protocol ResultSet {

    func advanceToNextRow() throws -> Bool
    func string(at index: Int) -> String?
    func int(at index: Int) -> Int
    func double(at index: Int) -> Double

}
