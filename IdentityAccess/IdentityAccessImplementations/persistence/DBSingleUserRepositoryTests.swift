//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import IdentityAccessImplementations
import IdentityAccessDomainModel

class DBSingleUserRepositoryTests: XCTestCase {

    let trace = FunctionCallTrace()
    var db: MockDatabase!
    var repository: DBSingleUserRepository!
    var userID: UserID!
    var user: User!

    override func setUp() {
        super.setUp()
        XCTAssertNoThrow(userID = try UserID())
        XCTAssertNoThrow(user = try User(id: userID, password: "MyPassword1"))
        db = MockDatabase(trace)
        repository = DBSingleUserRepository(db: db)
    }

    func test_setUp() throws {
        db.exists = false
        try repository.setUp()
        let expectedCalls = [
            "db.connection()",
            "conn.prepare(\(DBSingleUserRepository.SQL.createTable))",
            "stmt.execute()",
            "db.close()"]
        XCTAssertEqual(trace.log, expectedCalls, trace.diff(expectedCalls))
    }

    func test_save() throws {
        try repository.save(user)
        let expectedCalls = [
            "db.connection()",
            "conn.prepare(\(DBSingleUserRepository.SQL.insertUser))",
            "stmt.set(\(userID.id), 1)",
            "stmt.set(\(user.password), 2)",
            "stmt.execute()",
            "db.close()"]
        XCTAssertEqual(trace.log, expectedCalls, trace.diff(expectedCalls))
    }

    func test_remove() throws {
        try repository.remove(user)
        let expectedCalls = [
            "db.connection()",
            "conn.prepare(\(DBSingleUserRepository.SQL.deleteUser))",
            "stmt.set(\(userID.id), 1)",
            "stmt.execute()",
            "db.close()"]
        XCTAssertEqual(trace.log, expectedCalls, trace.diff(expectedCalls))
    }

    func test_primaryUser_databaseInteraction() {
        db.resultSet = [[user.id.id, user.password]]
        _ = repository.primaryUser()
        let expectedCalls = [
            "db.connection()",
            "conn.prepare(\(DBSingleUserRepository.SQL.findPrimaryUser))",
            "stmt.execute()",
            "rs.advanceToNextRow()",
            "rs.string(0)",
            "rs.string(1)",
            "db.close()"]
        XCTAssertEqual(trace.log, expectedCalls, trace.diff(expectedCalls))
    }

    func test_primaryUser_extractingValues() {
        db.resultSet = [[user.id.id, user.password]]
        let primaryUser = repository.primaryUser()
        XCTAssertEqual(primaryUser, user)
        XCTAssertEqual(primaryUser?.password, user.password)

        db.resultSet = []
        XCTAssertNil(repository.primaryUser())

        db.resultSet = [[user.id.id, nil]]
        XCTAssertNil(repository.primaryUser())

        db.resultSet = [[nil, "pass"]]
        XCTAssertNil(repository.primaryUser())

        db.resultSet = [[nil, nil]]
        XCTAssertNil(repository.primaryUser())
    }

    func test_nextID() {
        XCTAssertNotNil(repository.nextId())
    }

    func test_findByPassword_databaseInteraction() {
        db.resultSet = [[user.id.id, user.password]]
        _ = repository.user(encryptedPassword: user.password)
        let expectedCalls = [
            "db.connection()",
            "conn.prepare(\(DBSingleUserRepository.SQL.findUserByPassword))",
            "stmt.set(\(user.password), 1)",
            "stmt.execute()",
            "rs.advanceToNextRow()",
            "rs.string(0)",
            "rs.string(1)",
            "db.close()"]
        XCTAssertEqual(trace.log, expectedCalls, trace.diff(expectedCalls))
    }
}

class FunctionCallTrace {
    var log = [String]()

    func append(_ str: String) {
        log.append(str)
    }

    func diff(_ other: [String]) -> String {
        var diffs = [(String, String)]()
        log.enumerated().forEach { offset, logEntry in
            if !(0..<other.count).contains(offset) {
                diffs.append((logEntry, "MISSING"))
            } else if logEntry != other[offset] {
                diffs.append((logEntry, other[offset]))
            }
        }
        if other.count > log.count {
            diffs.append(contentsOf: other[log.count..<other.count].map { ("MISSING", $0) })
        }
        return diffs.map { "trace: \($0)\nother: \($1)" }.joined(separator: "\n---\n")
    }
}

typealias MockRawResultSet = [[Any?]]
class MockDatabase: Database {

    var exists: Bool = true
    var connections = [Connection]()
    private let trace: FunctionCallTrace
    var resultSet: MockRawResultSet?

    init(_ trace: FunctionCallTrace) {
        self.trace = trace
    }

    func create() throws {

    }

    func destroy() throws {

    }

    func connection() throws -> Connection {
        trace.append("db.connection()")
        let result = MockConnection(trace, resultSet)
        connections.append(result)
        return result
    }

    func close(_ connection: Connection) throws {
        trace.append("db.close()")
    }

}

class MockConnection: Connection {

    var statements = [MockStatement]()

    private let trace: FunctionCallTrace
    private var resultSet: MockRawResultSet?

    init(_ trace: FunctionCallTrace, _ resultSet: MockRawResultSet?) {
        self.trace = trace
        self.resultSet = resultSet
    }


    func prepare(statement: String) throws -> Statement {
        trace.append("conn.prepare(\(statement))")
        let result = MockStatement(trace, resultSet)
        statements.append(result)
        return result
    }

    func lastErrorMessage() -> String? {
        return nil
    }

}

class MockStatement: Statement {

    private let trace: FunctionCallTrace
    private var resultSet: MockRawResultSet?

    init(_ trace: FunctionCallTrace, _ resultSet: MockRawResultSet?) {
        self.trace = trace
        self.resultSet = resultSet
    }

    func set(_ value: String, at index: Int) throws {
        trace.append("stmt.set(\(value), \(index))")
    }

    func set(_ value: Int, at index: Int) throws {
        trace.append("stmt.set(\(value), \(index))")
    }

    func set(_ value: Double, at index: Int) throws {
        trace.append("stmt.set(\(value), \(index))")
    }

    func setNil(at index: Int) throws {
        trace.append("stmt.setNil(\(index))")
    }

    func set(_ value: String, forKey key: String) throws {
        trace.append("stmt.set(\(value), \(key))")
    }

    func set(_ value: Int, forKey key: String) throws {
        trace.append("stmt.set(\(value), \(key))")
    }

    func set(_ value: Double, forKey key: String) throws {
        trace.append("stmt.set(\(value), \(key))")
    }

    func setNil(forKey key: String) throws {
        trace.append("stmt.setNil(\(key))")
    }

    func execute() throws -> ResultSet? {
        trace.append("stmt.execute()")
        if let rs = resultSet {
            return MockResultSet(trace, rs)
        }
        return nil
    }

}

class MockResultSet: ResultSet {

    private let trace: FunctionCallTrace
    private var resultSet: MockRawResultSet
    private var currentRow: Int = -1

    init(_ trace: FunctionCallTrace, _ resultSet: MockRawResultSet) {
        self.trace = trace
        self.resultSet = resultSet
    }

    func advanceToNextRow() throws -> Bool {
        trace.append("rs.advanceToNextRow()")
        guard currentRow < resultSet.count && !resultSet.isEmpty else { return false }
        currentRow += 1
        return true
    }

    func string(at index: Int) -> String? {
        trace.append("rs.string(\(index))")
        return resultSet[currentRow][index] as? String
    }

    func int(at index: Int) -> Int {
        trace.append("rs.int(\(index))")
        return resultSet[currentRow][index] as? Int ?? 0
    }

    func double(at index: Int) -> Double {
        trace.append("rs.double(\(index))")
        return resultSet[currentRow][index] as? Double ?? 0
    }

}
