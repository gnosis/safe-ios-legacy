//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import IdentityAccessImplementations
import IdentityAccessDomainModel

class DBSingleGatekeeperRepositoryTests: XCTestCase {

    let trace = FunctionCallTrace()
    var db: MockDatabase!
    var repository: DBSingleGatekeeperRepository!

    override func setUp() {
        super.setUp()
        db = MockDatabase(trace)
        repository = DBSingleGatekeeperRepository(db: db)
    }

    func test_setUp() throws {
        try repository.setUp()
        let expectedCalls = [
            "db.connection()",
            "conn.prepare(\(DBSingleGatekeeperRepository.SQL.createTable))",
            "stmt.execute()",
            "db.close()"]
        XCTAssertEqual(trace.log, expectedCalls, trace.diff(expectedCalls))
    }

    func test_save() throws {
        let gatekeeper = try create()
        try repository.save(gatekeeper)
        let expectedCalls = [
            "db.connection()",
            "conn.prepare(\(DBSingleGatekeeperRepository.SQL.insertGatekeeper))",
            "stmt.set(\(gatekeeper.id.id), 1)",
            "stmt.set(\(try gatekeeper.data()), 2)",
            "stmt.execute()",
            "db.close()"]
        XCTAssertEqual(trace.log, expectedCalls, trace.diff(expectedCalls))
    }

    func test_remove() throws {
        let gatekeeper = try create()
        try repository.remove(gatekeeper)
        let expectedCalls = [
            "db.connection()",
            "conn.prepare(\(DBSingleGatekeeperRepository.SQL.deleteGatekeeper))",
            "stmt.set(\(gatekeeper.id.id), 1)",
            "stmt.execute()",
            "db.close()"]
        XCTAssertEqual(trace.log, expectedCalls, trace.diff(expectedCalls))
    }

    func test_gatekeeper() throws {
        let gatekeeper = try create()
        db.resultSet = [[gatekeeper.id.id, try gatekeeper.data()]]
        _ = repository.gatekeeper()
        let expectedCalls = [
            "db.connection()",
            "conn.prepare(\(DBSingleGatekeeperRepository.SQL.findGatekeeper))",
            "stmt.execute()",
            "rs.advanceToNextRow()",
            "rs.string(0)",
            "rs.data(1)",
            "db.close()"]
        XCTAssertEqual(trace.log, expectedCalls, trace.diff(expectedCalls))
    }

}

extension DBSingleGatekeeperRepositoryTests {

    func create() throws -> Gatekeeper {
        let policy = try AuthenticationPolicy(sessionDuration: 15,
                                              maxFailedAttempts: 5,
                                              blockDuration: 10)
        let gatekeeper = try Gatekeeper(id: repository.nextId(),
                                        policy: policy)
        return gatekeeper
    }

}
