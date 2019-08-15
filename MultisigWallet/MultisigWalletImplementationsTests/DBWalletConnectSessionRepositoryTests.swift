//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletImplementations
import MultisigWalletDomainModel
import Database

class DBWalletConnectSessionRepositoryTests: XCTestCase {

    func test_all() throws {
        let db = SQLiteDatabase(name: String(reflecting: self),
                                fileManager: FileManager.default,
                                sqlite: CSQLite3(),
                                bundleId: String(reflecting: self))
        try? db.destroy()
        try db.create()
        defer { try? db.destroy() }
        let repo = DBWalletConnectSessionRepository(db: db)
        repo.setUp()

        let session = WCSession.testSession
        repo.save(session)
        let restoredSession = repo.find(id: session.id)
        XCTAssertEqual(session, restoredSession)

        let allSessions = repo.all()
        XCTAssertEqual(allSessions.count, 1)
        XCTAssertEqual(allSessions[0], session)

        repo.remove(session)
        let notFoundSession = repo.find(id: session.id)
        XCTAssertNil(notFoundSession)
        let allSessionsNotFound = repo.all()
        XCTAssertTrue(allSessionsNotFound.isEmpty)
    }

}
