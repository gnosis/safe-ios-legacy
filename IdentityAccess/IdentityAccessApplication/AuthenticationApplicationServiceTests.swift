//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import IdentityAccessApplication

class AuthenticationApplicationServiceTests: ApplicationServiceTestCase {

    // register user

    func test_registerUser_createsUser() throws {
        try authenticationService.registerUser(password: "mypass")

    }

    // configure authentication

    // authenticate user

    // supported auth methods

    // possible auth methods

    // is blocked
    // is authenticated
    // session expiration

}
