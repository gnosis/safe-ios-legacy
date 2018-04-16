//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import IdentityAccessApplication

class AuthenticationApplicationServiceTests: ApplicationServiceTestCase {

    func test_registerUser_createsUser() throws {
        try authenticationService.registerUser(password: "MyPassword1")
        XCTAssertNotNil(userRepository.primaryUser())
    }

}
