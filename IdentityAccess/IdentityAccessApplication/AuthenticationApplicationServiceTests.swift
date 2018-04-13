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

    func test_authenticateUser_whenNotRegisteredThenFails() throws {
        let result = try authenticationService.authenticateUser(.password(password))
        XCTAssertEqual(result.status, .failure)
    }

    func test_authenticateUser_whenPasswordCorrect_thenSuccess() throws {
        _ = try authenticationService.registerUser(password: password)
        let result = try authenticationService.authenticateUser(.password(password))
        XCTAssertEqual(result.status, .success)
    }

}
