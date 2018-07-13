//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import IdentityAccessDomainModel

class UserTests: DomainTestCase {

    var id: UserID!
    let password = "123456A"

    override func setUp() {
        super.setUp()
        id = userRepository.nextId()
    }

    func test_assignSession_addsSession() throws {
        let sessionID = SessionID()
        let user = try createUser(password: password)
        user.attachSession(id: sessionID)
        XCTAssertEqual(user.sessionID, sessionID)
    }

}

extension UserTests {

    func createUser(password: String) throws -> User {
        return try User(id: id, password: password)
    }

}
