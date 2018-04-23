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

    public enum Error: Swift.Error, Hashable {
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
        return connection
    }

    public func close(_ connection: Connection) throws {
        try connection.close()
    }

    public func destroy() throws {
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
        try assertEqual(status, sqlite.SQLITE_OK, Database.Error.invalidSQLStatement)
        try assertNotNil(outStmt, Database.Error.invalidSQLStatement)
        let result = Statement(stmt: outStmt!, sqlite: sqlite)
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
        try assertEqual(status, sqlite.SQLITE_OK, Database.Error.failedToOpenDatabase)
        try assertNotNil(conn, Database.Error.failedToOpenDatabase)
        db = conn
        isOpened = true
    }

    func close() throws {
        try assertOpened()
        destroyAllStatements()
        let status = sqlite.sqlite3_close(db)
        try assertEqual(status, sqlite.SQLITE_OK, Database.Error.databaseBusy)
        isClosed = true
    }

}

public class Statement: Assertable {

    private let stmt: OpaquePointer
    private let sqlite: CSQLite3
    private var isFinalized: Bool = false

    init(stmt: OpaquePointer, sqlite: CSQLite3) {
        self.stmt = stmt
        self.sqlite = sqlite
    }

    public func execute() throws -> ResultSet {
        try assertFalse(isFinalized, Database.Error.attemptToExecuteFinalizedStatement)
        return ResultSet()
    }

    func finalize() {
        _ = sqlite.sqlite3_finalize(stmt)
        isFinalized = true
    }

}

public class ResultSet {
    public var isEmpty: Bool { return true }
}
