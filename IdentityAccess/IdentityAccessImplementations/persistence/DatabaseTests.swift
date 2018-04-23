//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import IdentityAccessImplementations

class DatabaseTests: XCTestCase {

    let fm = MockFileManager()
    let sqlite = MockCSQLite3()
    var db: Database!
    let bundleId = "my_random_bundle_id"

    enum Error: String, LocalizedError, Hashable {
        case databaseAlreadyExists
        case bundleIdentifierNotFound
        case databaseURLNotFound
        case resultSetMissing

        var errorDescription: String? {
            return rawValue
        }
    }

    override func setUp() {
        super.setUp()
        db = Database(name: "MyTestDb", fileManager: fm, sqlite: sqlite, bundleId: bundleId)
    }

    override func tearDown() {
        super.tearDown()
        XCTAssertNoThrow(try db.destroy())
    }

    func test_hasName() {
        XCTAssertEqual(db.name, "MyTestDb")
    }

    func test_whenAppSupportNotExists_thenThrows() throws {
        let appDirectory = try fm.appSupportURL()
        fm.notExistingURLs = [appDirectory]
        XCTAssertFalse(fm.fileExists(atPath: appDirectory.path))
        assertThrows(try db.create(), Database.Error.applicationSupportDirNotFound)
    }

    func test_whenDatabaseExists_thenThrrows() throws {
        let appDirectory = try fm.appSupportURL()
        let databaseURL = appDirectory.appendingPathComponent(bundleId)
            .appendingPathComponent(db.name)
            .appendingPathExtension("db")
        fm.existingURLs = [databaseURL]
        assertThrows(try db.create(), Database.Error.databaseAlreadyExists)
    }

    func test_createsDatabaseFile() throws {
        try db.create()
        guard let url = db.url else { throw Error.databaseURLNotFound }
        XCTAssertTrue(fm.fileExists(atPath: url.path))
    }

    func test_whenConnectingToNonExistingDatabase_thenThrows() throws {
        assertThrows(try db.connection(), Database.Error.databaseDoesNotExist)
    }

    func test_whenConnecting_thenOpensSqlite() throws {
        prepareDatabaseConnection()
        try db.create()
        _ = try db.connection()
        XCTAssertEqual(sqlite.openedFilename, db.url.path)
    }

    func test_beforeConnecting_whenVersionNotMatches_thenThrows() throws {
        sqlite.version = "1"
        sqlite.libversion_result = "2"
        try db.create()
        assertThrows(try db.connection(), Database.Error.invalidSQLiteVersion)
    }

    func test_beforeConnecting_whenSourceIDNotMatches_thenThrows() throws {
        sqlite.sourceID = "1"
        sqlite.sourceid_result = "2"
        try db.create()
        assertThrows(try db.connection(), Database.Error.invalidSQLiteVersion)
    }

    func test_beforeConnecting_whenVersionNumberNotMatches_thenThrows() throws {
        sqlite.number = 1
        sqlite.libversion_number_result = 2
        try db.create()
        assertThrows(try db.connection(), Database.Error.invalidSQLiteVersion)
    }

    func test_whenConnectionReturnsError_thenThrows() throws {
        sqlite.open_result = CSQLite3.SQLITE_IOERR_LOCK
        try db.create()
        assertThrows(try db.connection(), Database.Error.failedToOpenDatabase)
    }

    func test_whenConnectionReturnsNilPointer_thenThrows() throws {
        sqlite.open_pointer_result = nil
        try db.create()
        assertThrows(try db.connection(), Database.Error.failedToOpenDatabase)
    }

    func test_connectionClosesSQLiteDatabase() throws {
        prepareDatabaseConnection()
        sqlite.close_result = CSQLite3.SQLITE_OK
        try db.create()
        let conn = try db.connection()
        try db.close(conn)
        XCTAssertTrue(sqlite.close_pointer == sqlite.open_pointer_result)
    }

    func test_whenClosingNotPossible_throwsError() throws {
        prepareDatabaseConnection()
        sqlite.close_result = CSQLite3.SQLITE_BUSY
        try db.create()
        let conn = try db.connection()
        assertThrows(try db.close(conn), Database.Error.databaseBusy)
        sqlite.close_result = CSQLite3.SQLITE_OK
    }

    func test_whenClosingNotOpenConnection_throwsError() throws {
        let conn = Connection(sqlite: sqlite)
        assertThrows(try conn.close(), Database.Error.connectionIsNotOpened)
    }

    func test_whenNotOpenedAndPreparingStatement_thenThrows() {
        let conn = Connection(sqlite: sqlite)
        assertThrows(try conn.prepare(statement: "some"), Database.Error.connectionIsNotOpened)
    }

    func test_prepareStatement_passesCorrectArguments() throws {
        try db.create()
        sqlite.open_pointer_result = opaquePointer()
        sqlite.prepare_result = CSQLite3.SQLITE_OK
        sqlite.prepare_out_ppStmt = opaquePointer()
        sqlite.prepare_out_pzTail = nil

        let conn = try db.connection()
        _ = try conn.prepare(statement: "some")

        XCTAssertEqual(sqlite.prepare_in_db, sqlite.open_pointer_result)
        XCTAssertEqual(sqlite.prepare_in_zSql_string, "some")

        guard let bytes = sqlite.prepare_in_nByte else { XCTFail("Argument missing"); return }
        XCTAssertEqual(Int(bytes), "some".cString(using: .utf8)!.count)
    }

    func test_preapreStatement_whenFailed_thenThrowsError() throws {
        try db.create()
        sqlite.open_pointer_result = opaquePointer()
        sqlite.prepare_out_ppStmt = opaquePointer()
        sqlite.prepare_out_pzTail = nil

        sqlite.prepare_result = CSQLite3.SQLITE_ERROR

        let conn = try db.connection()
        assertThrows(try conn.prepare(statement: "some"), Database.Error.invalidSQLStatement)
    }

    func test_prepareStatement_whenReceivesNilStatement_thenThrowsError() throws {
        try db.create()
        sqlite.open_pointer_result = opaquePointer()
        sqlite.prepare_result = CSQLite3.SQLITE_OK
        sqlite.prepare_out_ppStmt = nil
        sqlite.prepare_out_pzTail = nil

        let conn = try db.connection()
        assertThrows(try conn.prepare(statement: "some"), Database.Error.invalidSQLStatement)
    }

    func test_whenConnectionIsClosed_thenPreparedStatementIsFinalizedAutomatically() throws {
        try db.create()

        sqlite.open_pointer_result = opaquePointer()
        let conn = try db.connection()

        sqlite.prepare_result = CSQLite3.SQLITE_OK
        sqlite.prepare_out_ppStmt = opaquePointer()
        sqlite.prepare_out_pzTail = nil
        _ = try conn.prepare(statement: "my statement")

        sqlite.finalize_result = CSQLite3.SQLITE_OK
        try db.close(conn)

        XCTAssertEqual(sqlite.finalize_in_pStmt, sqlite.prepare_out_ppStmt)
    }

    func test_whenMultipleStatementsCreated_finalizesAll() throws {
        try db.create()

        sqlite.open_pointer_result = opaquePointer()
        let conn = try db.connection()

        let stmt1 = opaquePointer()
        sqlite.prepare_result = CSQLite3.SQLITE_OK
        sqlite.prepare_out_ppStmt = stmt1
        sqlite.prepare_out_pzTail = nil
        _ = try conn.prepare(statement: "my statement")

        let stmt2 = opaquePointer()
        sqlite.prepare_result = CSQLite3.SQLITE_OK
        sqlite.prepare_out_ppStmt = stmt2
        sqlite.prepare_out_pzTail = nil
        _ = try conn.prepare(statement: "my othe statement")

        sqlite.finalize_result = CSQLite3.SQLITE_OK
        try db.close(conn)

        XCTAssertEqual(sqlite.finalize_in_pStmt_list, [stmt1, stmt2])

    }

    func test_whenStatementFinalizedAndExecutes_thenThrows() throws {
        let statement = Statement(sql: "some", db: opaquePointer(), stmt: opaquePointer(), sqlite: sqlite)
        statement.finalize()
        assertThrows(try statement.execute(), Database.Error.attemptToExecuteFinalizedStatement)
    }

    func test_whenConnectionWasClosedAndThenOpened_thenThrows() throws {
        try db.create()

        sqlite.open_pointer_result = opaquePointer()
        let conn = try db.connection()

        try db.close(conn)

        assertThrows(try conn.open(url: db.url), Database.Error.connectionIsAlreadyClosed)
    }

    func test_whenConnectionWasClosedAndThenClosedAgain_thenThrows() throws {
        try db.create()

        sqlite.open_pointer_result = opaquePointer()
        let conn = try db.connection()

        try db.close(conn)

        assertThrows(try db.close(conn), Database.Error.connectionIsAlreadyClosed)
    }

    func test_whenConnectionClosed_thenPrepareThrows() throws {
        try db.create()

        sqlite.open_pointer_result = opaquePointer()
        let conn = try db.connection()

        try db.close(conn)
        assertThrows(try conn.prepare(statement: "some"), Database.Error.connectionIsAlreadyClosed)
    }

    func test_whenDatabaseDestroyed_thenConnectionsAreClosed() throws {

    }

    func test_whenDatabaseDeinit_thenConnectionsAreClosed() throws {
        try db.create()

        sqlite.open_pointer_result = opaquePointer()
        let conn = try db.connection()

        try db.destroy()

        assertThrows(try conn.prepare(statement: "some"), Database.Error.connectionIsAlreadyClosed)
    }

    func test_canCreateAfterDestroy() throws {
        try db.create()
        sqlite.open_pointer_result = opaquePointer()
        _ = try db.connection()
        try db.destroy()
        try db.create()
        try db.destroy()
    }

    func test_execute_whenStepReturnsDone_thenOk() throws {
        try db.create()
        sqlite.open_pointer_result = opaquePointer()
        let conn = try db.connection()
        sqlite.prepare_out_ppStmt = opaquePointer()
        let stmt = try conn.prepare(statement: "some")
        try stmt.execute()
        XCTAssertNotNil(sqlite.step_in_pStmt)
    }

    func test_whenExecutedAndExecutesAgain_thenThrows() throws {
        try db.create()
        sqlite.open_pointer_result = opaquePointer()
        let conn = try db.connection()
        sqlite.prepare_out_ppStmt = opaquePointer()
        let stmt = try conn.prepare(statement: "some")
        try stmt.execute()
        assertThrows(try stmt.execute(), Database.Error.statementWasAlreadyExecuted)
    }

    func test_whenExecuteError_thenThrows() throws {
        try db.create()
        sqlite.open_pointer_result = opaquePointer()
        let conn = try db.connection()
        sqlite.prepare_out_ppStmt = opaquePointer()
        let stmt = try conn.prepare(statement: "some")
        sqlite.step_results = [CSQLite3.SQLITE_ERROR]
        assertThrows(try stmt.execute(), Database.Error.runtimeError)
    }

    func test_whenExecuteMisuse_thenTrows() throws {
        try db.create()
        sqlite.open_pointer_result = opaquePointer()
        let conn = try db.connection()
        sqlite.prepare_out_ppStmt = opaquePointer()
        let stmt = try conn.prepare(statement: "some")
        sqlite.step_results = [CSQLite3.SQLITE_MISUSE]
        assertThrows(try stmt.execute(), Database.Error.invalidStatementState)
    }

    func test_whenStatementIsNotCommitAndOccursInsideExplicitTransaction_thenThrows() throws {
        try db.create()
        sqlite.open_pointer_result = opaquePointer()
        let conn = try db.connection()
        sqlite.prepare_out_ppStmt = opaquePointer()
        let stmt = try conn.prepare(statement: "some")
        sqlite.step_results = [CSQLite3.SQLITE_BUSY]
        // 0 means False - autocommit is disabled - inside BEGIN...COMMIT
        sqlite.get_autocommit_result = 0
        assertThrows(try stmt.execute(), Database.Error.transactionMustBeRolledBack)
    }

    func test_whenStatementIsCommitAndBusy_thenRetries() throws {
        try db.create()
        sqlite.open_pointer_result = opaquePointer()
        let conn = try db.connection()
        sqlite.prepare_out_ppStmt = opaquePointer()
        let stmt = try conn.prepare(statement: "COMMIT;")
        sqlite.step_results = [CSQLite3.SQLITE_BUSY, CSQLite3.SQLITE_BUSY, CSQLite3.SQLITE_DONE]
        try stmt.execute()
        XCTAssertEqual(sqlite.step_result_index, sqlite.step_results.count)
    }

    func test_whenStatementNotCommitAndBusyAndOutsideExplicitTransaction_thenRetries() throws {
        try db.create()
        sqlite.open_pointer_result = opaquePointer()
        let conn = try db.connection()
        sqlite.prepare_out_ppStmt = opaquePointer()
        let stmt = try conn.prepare(statement: "some")
        sqlite.step_results = [CSQLite3.SQLITE_BUSY, CSQLite3.SQLITE_BUSY, CSQLite3.SQLITE_DONE]
        // autocommit enabled - means not in BEGIN...COMMIT
        sqlite.get_autocommit_result = 1
        try stmt.execute()
        XCTAssertEqual(sqlite.step_result_index, sqlite.step_results.count)
    }

    func test_whenStatementProducesResult_thenReturnsResultSet() throws {
        try db.create()
        sqlite.open_pointer_result = opaquePointer()
        let conn = try db.connection()
        sqlite.prepare_out_ppStmt = opaquePointer()
        let stmt = try conn.prepare(statement: "some")
        sqlite.step_results = [CSQLite3.SQLITE_ROW]
        let rs = try stmt.execute()
        XCTAssertNotNil(rs)
    }

    func test_whenStatementHasNoColumns_thenReturns() throws {
        try db.create()
        sqlite.open_pointer_result = opaquePointer()
        let conn = try db.connection()
        sqlite.prepare_out_ppStmt = opaquePointer()
        let stmt = try conn.prepare(statement: "some")
        sqlite.step_results = [CSQLite3.SQLITE_ROW]
        guard let rs = try stmt.execute() else { throw Error.resultSetMissing }
        sqlite.column_count_result = 0
        XCTAssertTrue(rs.isColumnsEmpty)
        XCTAssertNotNil(sqlite.column_count_in_pStmt)
    }

    func test_resultSetColumnCount() throws {
        try db.create()
        sqlite.open_pointer_result = opaquePointer()
        let conn = try db.connection()
        sqlite.prepare_out_ppStmt = opaquePointer()
        let stmt = try conn.prepare(statement: "some")
        sqlite.step_results = [CSQLite3.SQLITE_ROW]
        guard let rs = try stmt.execute() else { throw Error.resultSetMissing }
        sqlite.column_count_result = 15
        XCTAssertEqual(rs.columnCount, 15)
    }

    func test_resultSet_columnValues() throws {
        try db.create()
        sqlite.open_pointer_result = opaquePointer()
        let conn = try db.connection()
        sqlite.prepare_out_ppStmt = opaquePointer()
        let stmt = try conn.prepare(statement: "some")
        sqlite.step_results = [CSQLite3.SQLITE_ROW]
        guard let rs = try stmt.execute() else { throw Error.resultSetMissing }
        sqlite.column_count_result = 3
        sqlite.column_text_result = "some"
        sqlite.column_bytes_result = Int32("some".cString(using: .utf8)!.count)
        XCTAssertEqual(rs.string(at: 2), "some")

        sqlite.column_int64_result = Int64(1)
        XCTAssertEqual(rs.int(at: 1), 1)

        sqlite.column_double_result = 5.3
        XCTAssertEqual(rs.double(at: 0), 5.3, accuracy: 0.001)
    }

    func test_whenReturnsRow_thenResetsQuery() throws {
        // query reset so that ResultSet.advanceToNextRow() can be used
        try db.create()
        sqlite.open_pointer_result = opaquePointer()
        let conn = try db.connection()
        sqlite.prepare_out_ppStmt = opaquePointer()
        let stmt = try conn.prepare(statement: "some")
        sqlite.step_results = [CSQLite3.SQLITE_ROW]
        try stmt.execute()
        XCTAssertNotNil(sqlite.reset_in_pStmt)
    }

    func test_whenReturns2Rows_thenCanAdvance2Times() throws {
        // query reset so that ResultSet.advanceToNextRow() can be used
        try db.create()
        sqlite.open_pointer_result = opaquePointer()
        let conn = try db.connection()
        sqlite.prepare_out_ppStmt = opaquePointer()
        let stmt = try conn.prepare(statement: "some")
        sqlite.step_results = [CSQLite3.SQLITE_ROW, // called by execute()
            CSQLite3.SQLITE_ROW, // advanceToNextRow()
            CSQLite3.SQLITE_ROW,
            CSQLite3.SQLITE_DONE]
        guard let rs = try stmt.execute() else { throw Error.resultSetMissing }
        XCTAssertTrue(try rs.advanceToNextRow())
        XCTAssertTrue(try rs.advanceToNextRow())
        XCTAssertFalse(try rs.advanceToNextRow())
    }

    func test_whenOutsideOfExplicitTransactionAndBusyDuringAdvancing_thenRetries() throws {
        try db.create()
        sqlite.open_pointer_result = opaquePointer()
        let conn = try db.connection()
        sqlite.prepare_out_ppStmt = opaquePointer()
        let stmt = try conn.prepare(statement: "some")
        sqlite.get_autocommit_result = 1
        sqlite.step_results = [CSQLite3.SQLITE_ROW, // called by execute()
            CSQLite3.SQLITE_ROW, // advanceToNextRow()
            CSQLite3.SQLITE_BUSY,
            CSQLite3.SQLITE_BUSY,
            CSQLite3.SQLITE_ROW,
            CSQLite3.SQLITE_DONE]
        guard let rs = try stmt.execute() else { throw Error.resultSetMissing }
        XCTAssertTrue(try rs.advanceToNextRow())
        XCTAssertTrue(try rs.advanceToNextRow())
        XCTAssertFalse(try rs.advanceToNextRow())
    }

}

// connection can go through all its statements

extension DatabaseTests {

    private func prepareDatabaseConnection() {
        sqlite.open_pointer_result = opaquePointer()
    }

    func opaquePointer() -> OpaquePointer {
        return String(repeating: "a", count: 1 + Int(arc4random_uniform(10))).withCString {
            ptr -> OpaquePointer in OpaquePointer.init(ptr)
        }
    }

    func assertThrows<T, E: Swift.Error & Hashable>(_ expression: @autoclosure () throws -> T,
                                                    _ error: E,
                                                    file: StaticString = #file,
                                                    line: UInt = #line,
                                                    function: StaticString = #function) {
        XCTAssertThrowsError(expression, file: file, line: line) {
            XCTAssertEqual($0 as? E, error, file: file, line: line)
        }
    }
}

class MockFileManager: FileManager {

    func appSupportURL() throws -> URL {
        return try url(for: .applicationSupportDirectory,
                       in: .userDomainMask,
                       appropriateFor: nil,
                       create: false)
    }

    var notExistingURLs = [URL]()
    var existingURLs = [URL]()

    override func fileExists(atPath path: String) -> Bool {
        if existingURLs.map({ $0.path }).contains(path) { return true }
        if notExistingURLs.map({ $0.path }).contains(path) { return false }
        return super.fileExists(atPath: path)
    }

    override func removeItem(at URL: URL) throws {
        if let index = existingURLs.index(of: URL) {
            existingURLs.remove(at: index)
            if !super.fileExists(atPath: URL.path) {
                return
            }
        }
        try super.removeItem(at: URL)
    }
}
