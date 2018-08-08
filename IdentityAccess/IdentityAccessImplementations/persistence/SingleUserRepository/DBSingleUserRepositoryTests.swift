//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import IdentityAccessImplementations
import IdentityAccessDomainModel
import Database

class DBSingleUserRepositoryTests: XCTestCase {

    let trace = FunctionCallTrace()
    var db: MockDatabase!
    var repository: DBSingleUserRepository!
    var userID = UserID()
    var user: User!

    override func setUp() {
        super.setUp()
        user = User(id: userID, password: "MyPassword1")
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
            "stmt.setNil(3)",
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
        db.resultSet = [[user.id.id, user.password, nil]]
        _ = repository.primaryUser()
        let expectedCalls = [
            "db.connection()",
            "conn.prepare(\(DBSingleUserRepository.SQL.findPrimaryUser))",
            "stmt.execute()",
            "rs.advanceToNextRow()",
            "rs.string(0)",
            "rs.string(1)",
            "rs.string(2)",
            "rs.advanceToNextRow()",
            "db.close()"]
        XCTAssertEqual(trace.log, expectedCalls, trace.diff(expectedCalls))
    }

    func test_primaryUser_extractingValues() throws {
        let sessionID = SessionID()
        user.attachSession(id: sessionID)
        db.resultSet = [[user.id.id, user.password, user.sessionID?.id]]
        let primaryUser = repository.primaryUser()
        XCTAssertEqual(primaryUser, user)
        XCTAssertEqual(primaryUser?.password, user.password)
        XCTAssertEqual(primaryUser?.sessionID, sessionID)

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
        db.resultSet = [[user.id.id, user.password, nil]]
        _ = repository.user(encryptedPassword: user.password)
        let expectedCalls = [
            "db.connection()",
            "conn.prepare(\(DBSingleUserRepository.SQL.findUserByPassword))",
            "stmt.set(\(user.password), 1)",
            "stmt.execute()",
            "rs.advanceToNextRow()",
            "rs.string(0)",
            "rs.string(1)",
            "rs.string(2)",
            "rs.advanceToNextRow()",
            "db.close()"]
        XCTAssertEqual(trace.log, expectedCalls, trace.diff(expectedCalls))
    }
}
