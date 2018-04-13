//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import IdentityAccessDomainModel

class UserTests: DomainTestCase {

    func test_canCreate() {
        let id = UserID("ID")
        let user = User(id: id, password: "MyPassword")
        XCTAssertNotNil(user.userID)
    }

}
