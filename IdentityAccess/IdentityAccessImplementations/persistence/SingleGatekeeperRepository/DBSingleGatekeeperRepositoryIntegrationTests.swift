//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import IdentityAccessImplementations
import IdentityAccessDomainModel
import Database

class DBSingleGatekeeperRepositoryIntegrationTests: XCTestCase {

    func test_all() throws {
        let db = SQLiteDatabase(name: "DBSingleGatekeeperRepositoryIntegrationTests",
                                fileManager: FileManager.default,
                                sqlite: CSQLite3(),
                                bundleId: "DBSingleGatekeeperRepositoryIntegrationTests")
        try? db.destroy()
        try db.create()
        defer { try? db.destroy() }
        let repo = DBSingleGatekeeperRepository(db: db)
        try repo.setUp()
        let gatekeeper = try Gatekeeper(id: repo.nextId(),
                                        policy: AuthenticationPolicy(sessionDuration: 5,
                                                                     maxFailedAttempts: 5,
                                                                     blockDuration: 5))
        try repo.save(gatekeeper)
        let saved = repo.gatekeeper()
        XCTAssertEqual(saved, gatekeeper)
        XCTAssertEqual(saved?.policy, gatekeeper.policy)
        try repo.remove(gatekeeper)
        XCTAssertNil(repo.gatekeeper())
    }

}
