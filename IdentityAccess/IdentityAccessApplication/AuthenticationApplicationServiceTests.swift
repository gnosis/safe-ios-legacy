//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import IdentityAccessApplication

class AuthenticationApplicationServiceTests: ApplicationServiceTestCase {

    let password = "MyPassword1"

    func test_registerUser_createsUser() throws {
        try authenticationService.registerUser(password: password)
        XCTAssertNotNil(userRepository.primaryUser())
    }

//    func test_authenticateUser_whenEmptyThenFails() throws {
//        let user = try authenticationService.authenticateUser(method: .password, password)
//        XCTAssertNil(user)
//    }

    // empty password throws
    // wrong password nils out or returns null user data object
    // authenticates with encrypted password - from repository

}
