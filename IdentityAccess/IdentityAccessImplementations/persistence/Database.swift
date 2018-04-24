//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public class Database: Assertable {

    public let name: String
    public var exists: Bool { return false }
    public var url: URL!
    private let fileManager: FileManager
    private let sqlite: CSQLite3
    private let bundleIdentifier: String
    private var connections = [Connection]()

    public enum Error: String, Hashable, LocalizedError {
        case applicationSupportDirNotFound
        case bundleIdentifierNotFound
        case databaseAlreadyExists
        case failedToCreateDatabase
        case databaseDoesNotExist
        case invalidSQLiteVersion
        case failedToOpenDatabase
        case databaseBusy
        case connectionIsNotOpened
        case invalidSQLStatement
        case attemptToExecuteFinalizedStatement
        case connectionIsAlreadyClosed
        case statementWasAlreadyExecuted
        case runtimeError
        case invalidStatementState
        case transactionMustBeRolledBack
        case invalidStringBindingValue
        case failedToSetStatementParameter
        case statementParameterIndexOutOfRange
        case invalidKeyValue
        case attemptToBindExecutedStatement
        case attemptToBindFinalizedStatement

        public var errorDescription: String? {
            return rawValue
        }
    }

    public init(name: String, fileManager: FileManager, sqlite: CSQLite3, bundleId: String) {
        self.name = name
        self.fileManager = fileManager
        self.sqlite = sqlite
        self.bundleIdentifier = bundleId
    }

    public func create() throws {
        try buildURL()
        try assertFalse(fileManager.fileExists(atPath: url.path), Error.databaseAlreadyExists)
        let attributes = [FileAttributeKey.protectionKey: FileProtectionType.completeUnlessOpen]
        let didCreate = fileManager.createFile(atPath: url.path, contents: nil, attributes: attributes)
        if !didCreate {
            throw Error.failedToCreateDatabase
        }
    }

    public func connection() throws -> Connection {
        try buildURL()
        try assertTrue(fileManager.fileExists(atPath: url.path), Error.databaseDoesNotExist)
        try assertEqual(String(cString: sqlite.sqlite3_libversion()), sqlite.SQLITE_VERSION, Error.invalidSQLiteVersion)
        try assertEqual(String(cString: sqlite.sqlite3_sourceid()), sqlite.SQLITE_SOURCE_ID, Error.invalidSQLiteVersion)
        try assertEqual(sqlite.sqlite3_libversion_number(), sqlite.SQLITE_VERSION_NUMBER, Error.invalidSQLiteVersion)
        let connection = Connection(sqlite: sqlite)
        try connection.open(url: url)
        connections.append(connection)
        return connection
    }

    public func close(_ connection: Connection) throws {
        try connection.close()
        if let index = connections.index(where: { $0 === connection }) {
            connections.remove(at: index)
        }
    }

    public func destroy() throws {
        try connections.forEach { try $0.close() }
        connections.removeAll()
        guard let url = url else { return }
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
    }

    private func buildURL() throws {
        if url != nil { return }
        let appSupportDir = try fileManager.url(for: .applicationSupportDirectory,
                                                in: .userDomainMask,
                                                appropriateFor: nil,
                                                create: true)
        try assertTrue(fileManager.fileExists(atPath: appSupportDir.path), Error.applicationSupportDirNotFound)
        let bundleDir = appSupportDir.appendingPathComponent(bundleIdentifier, isDirectory: true)
        if !fileManager.fileExists(atPath: bundleDir.path) {
            try fileManager.createDirectory(at: bundleDir, withIntermediateDirectories: false, attributes: nil)
        }
        self.url = bundleDir.appendingPathComponent(name).appendingPathExtension("db")
    }

}

public class Connection: Assertable {

    private var db: OpaquePointer!
    private let sqlite: CSQLite3
    private var isOpened = false
    private var isClosed = false
    private var statements = [Statement]()

    init(sqlite: CSQLite3) {
        self.sqlite = sqlite
    }

    public func prepare(statement: String) throws -> Statement {
        try assertOpened()
        guard let cstr = statement.cString(using: .utf8) else {
            preconditionFailure("Failed to convert String to C String: \(statement)")
        }
        var outStmt: OpaquePointer?
        var outTail: UnsafePointer<Int8>?
        let status = sqlite.sqlite3_prepare_v2(db, cstr, Int32(cstr.count), &outStmt, &outTail)
        try assertEqual(status, CSQLite3.SQLITE_OK, Database.Error.invalidSQLStatement)
        try assertNotNil(outStmt, Database.Error.invalidSQLStatement)
        let result = Statement(sql: statement, db: db, stmt: outStmt!, sqlite: sqlite)
        statements.append(result)
        return result
    }

    private func assertOpened() throws {
        try assertTrue(isOpened, Database.Error.connectionIsNotOpened)
        try assertFalse(isClosed, Database.Error.connectionIsAlreadyClosed)
    }

    private func destroyAllStatements() {
        statements.forEach { $0.finalize() }
    }

    func open(url: URL) throws {
        try assertFalse(isClosed, Database.Error.connectionIsAlreadyClosed)
        var conn: OpaquePointer?
        let status = sqlite.sqlite3_open(url.path.cString(using: .utf8), &conn)
        try assertEqual(status, CSQLite3.SQLITE_OK, Database.Error.failedToOpenDatabase)
        try assertNotNil(conn, Database.Error.failedToOpenDatabase)
        db = conn
        isOpened = true
    }

    func close() throws {
        try assertOpened()
        destroyAllStatements()
        let status = sqlite.sqlite3_close(db)
        try assertEqual(status, CSQLite3.SQLITE_OK, Database.Error.databaseBusy)
        isClosed = true
    }

}

public class Statement: Assertable {

    private let sql: String
    private let db: OpaquePointer
    private let stmt: OpaquePointer
    private let sqlite: CSQLite3
    private var isFinalized: Bool = false
    private var isExecuted: Bool = false

    init(sql: String, db: OpaquePointer, stmt: OpaquePointer, sqlite: CSQLite3) {
        self.sql = sql
        self.db = db
        self.stmt = stmt
        self.sqlite = sqlite
    }

    @discardableResult
    public func execute() throws -> ResultSet? {
        try assertFalse(isFinalized, Database.Error.attemptToExecuteFinalizedStatement)
        try assertFalse(isExecuted, Database.Error.statementWasAlreadyExecuted)
        let status = sqlite.sqlite3_step(stmt)
        switch status {
        case CSQLite3.SQLITE_DONE:
            isExecuted = true
            return nil
        case CSQLite3.SQLITE_ROW:
            isExecuted = true
            return ResultSet(db: db, stmt: stmt, sqlite: sqlite)
        case CSQLite3.SQLITE_BUSY:
            let isInsideExplicitTransaction = sqlite.sqlite3_get_autocommit(db) == 0
            let isCommitStatement = sql.localizedCaseInsensitiveContains("commit")
            if isCommitStatement || !isInsideExplicitTransaction {
                RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.01))
                return try execute()
            } else {
                throw Database.Error.transactionMustBeRolledBack
            }
        case CSQLite3.SQLITE_ERROR:
            throw Database.Error.runtimeError
        case CSQLite3.SQLITE_MISUSE:
            throw Database.Error.invalidStatementState
        default:
            preconditionFailure("Unexpected sqlite3_step() status: \(status)")
        }
    }

    func finalize() {
        _ = sqlite.sqlite3_finalize(stmt)
        isFinalized = true
    }

    public func set(_ value: String, at index: Int) throws {
        try assertCanBind()
        guard let cString = value.cString(using: .utf8) else { throw Database.Error.invalidStringBindingValue }
        let status = sqlite.sqlite3_bind_text(stmt,
                                              Int32(index),
                                              cString,
                                              Int32(cString.count),
                                              CSQLite3.SQLITE_TRANSIENT)
        try assertBindSuccess(status)
    }

    public func set(_ value: Int, at index: Int) throws {
        try assertCanBind()
        let status = sqlite.sqlite3_bind_int64(stmt, Int32(index), Int64(value))
        try assertBindSuccess(status)
    }

    public func set(_ value: Double, at index: Int) throws {
        try assertCanBind()
        let status = sqlite.sqlite3_bind_double(stmt, Int32(index), value)
        try assertBindSuccess(status)
    }

    public func setNil(at index: Int) throws {
        try assertCanBind()
        let status = sqlite.sqlite3_bind_null(stmt, Int32(index))
        try assertBindSuccess(status)
    }

    public func set(_ value: String, forKey key: String) throws {
        let index = try parameterIndex(for: key)
        try set(value, at: index)
    }

    public func set(_ value: Int, forKey key: String) throws {
        let index = try parameterIndex(for: key)
        try set(value, at: index)
    }

    public func set(_ value: Double, forKey key: String) throws {
        let index = try parameterIndex(for: key)
        try set(value, at: index)
    }

    public func setNil(forKey key: String) throws {
        let index = try parameterIndex(for: key)
        try setNil(at: index)
    }

    private func assertCanBind() throws {
        try assertFalse(isExecuted, Database.Error.attemptToBindExecutedStatement)
        try assertFalse(isFinalized, Database.Error.attemptToBindFinalizedStatement)
    }

    private func assertBindSuccess(_ status: Int32) throws {
        try assertNotEqual(status, CSQLite3.SQLITE_RANGE, Database.Error.statementParameterIndexOutOfRange)
        try assertEqual(status, CSQLite3.SQLITE_OK, Database.Error.failedToSetStatementParameter)
    }

    private func parameterIndex(for key: String) throws -> Int {
        guard let cString = key.cString(using: .utf8) else { throw Database.Error.invalidKeyValue }
        let index = sqlite.sqlite3_bind_parameter_index(stmt, cString)
        return Int(index)
    }

}

public class ResultSet {

    public var isColumnsEmpty: Bool { return columnCount == 0 }
    public var columnCount: Int { return Int(sqlite.sqlite3_column_count(stmt)) }
    private let stmt: OpaquePointer
    private let sqlite: CSQLite3
    private let db: OpaquePointer

    init(db: OpaquePointer, stmt: OpaquePointer, sqlite: CSQLite3) {
        self.db = db
        self.stmt = stmt
        self.sqlite = sqlite
        let status = sqlite.sqlite3_reset(stmt)
        precondition(status == CSQLite3.SQLITE_OK)
    }

    public func string(at index: Int) -> String? {
        assertIndex(index)
        guard let cString = sqlite.sqlite3_column_text(stmt, Int32(index)) else {
            return nil
        }
        let bytesCount = sqlite.sqlite3_column_bytes(stmt, Int32(index))
        return cString.withMemoryRebound(to: CChar.self, capacity: Int(bytesCount)) { ptr -> String? in
            String(cString: ptr, encoding: .utf8)
        }
    }

    private func assertIndex(_ index: Int) {
        precondition((0..<columnCount).contains(index), "Index out of column count range")
    }

    public func int(at index: Int) -> Int {
        assertIndex(index)
        return Int(sqlite.sqlite3_column_int64(stmt, Int32(index)))
    }

    public func double(at index: Int) -> Double {
        assertIndex(index)
        return sqlite.sqlite3_column_double(stmt, Int32(index))
    }

    public func advanceToNextRow() throws -> Bool {
        let status = sqlite.sqlite3_step(stmt)
        switch status {
        case CSQLite3.SQLITE_DONE:
            return false
        case CSQLite3.SQLITE_ROW:
            return true
        case CSQLite3.SQLITE_BUSY:
            let isOutsideOfExplicitTransaction = sqlite.sqlite3_get_autocommit(db) == 1
            if isOutsideOfExplicitTransaction {
                RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.01))
                return try advanceToNextRow()
            } else {
                throw Database.Error.transactionMustBeRolledBack
            }
        default:
            preconditionFailure("Unexpected sqlite3_step() status: \(status)")
        }
    }
}
