//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

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
