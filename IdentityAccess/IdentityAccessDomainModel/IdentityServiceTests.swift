//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import IdentityAccessDomainModel

class IdentityServiceTests: DomainTestCase {

    let service = IdentityService()
    let password = "MyPassword1"

    func test_registerUser_savesInRepository() throws {
        let user = try service.registerUser(password: password)
        XCTAssertEqual(userRepository.primaryUser(), user)
    }

    func test_registerUser_cannotRegisterTwice() throws {
        _ = try service.registerUser(password: password)
        XCTAssertThrowsError(try identityService.registerUser(password: password)) {
            XCTAssertEqual($0 as? IdentityService.Error, .userAlreadyRegistered)
        }
    }

    func test_registerUser_activatesBiometry() throws {
        _ = try service.registerUser(password: password)
        XCTAssertTrue(biometricService.didActivate)
    }

    func test_registerUser_storesEncryptedPassword() throws {
        let user = try service.registerUser(password: password)
        XCTAssertEqual(user.password, encryptionService.encrypted(password))
    }

    func test_authenticateUser_whenEmptyPassword_thenThrowsError() {
        XCTAssertThrowsError(try service.authenticateUser(password: "")) {
            XCTAssertEqual($0 as? IdentityService.Error, .emptyPassword)
        }
    }

    func test_authenticateUser_whenNotRegistered_thenReturnsNil() {
        XCTAssertNil(try service.authenticateUser(password: "some"))
    }

    func test_authenticateUser_whenCorrectPassword_thenSuccess() throws {
        let user = try service.registerUser(password: password)
        XCTAssertEqual(try service.authenticateUser(password: password), user)
    }

}
