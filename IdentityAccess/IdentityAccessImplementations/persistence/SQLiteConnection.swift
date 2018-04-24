//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public class SQLiteConnection: Assertable {

    private var db: OpaquePointer!
    private let sqlite: CSQLite3
    private var isOpened = false
    private var isClosed = false
    private var statements = [SQLiteStatement]()

    init(sqlite: CSQLite3) {
        self.sqlite = sqlite
    }

    public func prepare(statement: String) throws -> SQLiteStatement {
        try assertOpened()
        guard let cstr = statement.cString(using: .utf8) else {
            preconditionFailure("Failed to convert String to C String: \(statement)")
        }
        var outStmt: OpaquePointer?
        var outTail: UnsafePointer<Int8>?
        let status = sqlite.sqlite3_prepare_v2(db, cstr, Int32(cstr.count), &outStmt, &outTail)
        try assertEqual(status, CSQLite3.SQLITE_OK, SQLiteDatabase.Error.invalidSQLStatement)
        try assertNotNil(outStmt, SQLiteDatabase.Error.invalidSQLStatement)
        let result = SQLiteStatement(sql: statement, db: db, stmt: outStmt!, sqlite: sqlite)
        statements.append(result)
        return result
    }

    private func assertOpened() throws {
        try assertTrue(isOpened, SQLiteDatabase.Error.connectionIsNotOpened)
        try assertFalse(isClosed, SQLiteDatabase.Error.connectionIsAlreadyClosed)
    }

    private func destroyAllStatements() {
        statements.forEach { $0.finalize() }
    }

    func open(url: URL) throws {
        try assertFalse(isClosed, SQLiteDatabase.Error.connectionIsAlreadyClosed)
        var conn: OpaquePointer?
        let status = sqlite.sqlite3_open(url.path.cString(using: .utf8), &conn)
        try assertEqual(status, CSQLite3.SQLITE_OK, SQLiteDatabase.Error.failedToOpenDatabase)
        try assertNotNil(conn, SQLiteDatabase.Error.failedToOpenDatabase)
        db = conn
        isOpened = true
    }

    func close() throws {
        try assertOpened()
        destroyAllStatements()
        let status = sqlite.sqlite3_close(db)
        try assertEqual(status, CSQLite3.SQLITE_OK, SQLiteDatabase.Error.databaseBusy)
        isClosed = true
    }

}
