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

    enum Error: Swift.Error, Hashable {
        case databaseAlreadyExists
        case bundleIdentifierNotFound
        case databaseURLNotFound
    }

//    func test_whenCondition_thenResult() throws {
//        let db = Database(name: "identityAccessImplementationTests", fileManager: fm)
//        if db.exists { throw Error.databaseAlreadyExists }
//        try db.create()
//        let connection = try db.connection()
//        let statement = try connection.prepare(statement: "CREATE TABLE tbl_metadata (version INTEGER NOT NULL);")
//        let resultSet = try statement.execute()
//        XCTAssertTrue(resultSet.isEmpty)
//        try db.destroy()
//    }

    override func setUp() {
        super.setUp()
        db = Database(name: "MyTestDb", fileManager: fm, sqlite: sqlite, bundleId: bundleId)
    }

    override func tearDown() {
        super.tearDown()
        try? db.destroy()
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
        sqlite.open_result = sqlite.SQLITE_IOERR_LOCK
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
        sqlite.close_result = sqlite.SQLITE_OK
        try db.create()
        let conn = try db.connection()
        try db.close(conn)
        XCTAssertTrue(sqlite.close_pointer == sqlite.open_pointer_result)
    }

    func test_whenClosingNotPossible_throwsError() throws {
        prepareDatabaseConnection()
        sqlite.close_result = sqlite.SQLITE_BUSY
        try db.create()
        let conn = try db.connection()
        assertThrows(try db.close(conn), Database.Error.databaseBusy)
    }

    func test_whenClosingNotOpenConnection_throwsError() throws {
        let conn = Connection(sqlite: sqlite)
        assertThrows(try conn.close(), Database.Error.connectionIsNotOpened)
    }

    func test_whenNotOpenedAndPreparingStatement_thenThrows() {
        let conn = Connection(sqlite: sqlite)
        assertThrows(try conn.prepare(statement: "some"), Database.Error.connectionIsNotOpened)
    }

    func test_prepareStatement() throws {
        try db.create()
        sqlite.open_pointer_result = opaquePointer()
        sqlite.prepare_result = sqlite.SQLITE_OK
        sqlite.prepare_out_ppStmt = opaquePointer()
        sqlite.prepare_out_pzTail = nil
        let conn = try db.connection()
        _ = try conn.prepare(statement: "some")
        XCTAssertEqual(sqlite.prepare_in_db, sqlite.open_pointer_result)
        guard let ptr = sqlite.prepare_in_zSql else { XCTFail("Argument missing"); return }
        XCTAssertEqual(String(cString: ptr), "some")
        guard let bytes = sqlite.prepare_in_nByte else { XCTFail("Argument missing"); return }
        XCTAssertEqual(Int(bytes), "some".cString(using: .utf8)!.count)
    }

//    func test_whenClosingConnection_preapredStatementFinalized() {
//        let conn = Connection(sqlite: sqlite)
//        try conn.open(url: db.url)
//        let stmt = try conn.prepare(statement: "some")
//        try conn.close()
//    }
}

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
}
