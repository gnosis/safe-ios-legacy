//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import IdentityAccessDomainModel

class IdentityServiceTests: DomainTestCase {

    let service = IdentityService()
    let password = "MyPassword1"

    func test_registerUser_savesInRepository() throws {
        let user = try givenRegisteredUser()
        XCTAssertEqual(userRepository.primaryUser(), user)
    }

    func test_registerUser_cannotRegisterTwice() throws {
        try givenRegisteredUser()
        XCTAssertThrowsError(try registerAgain()) {
            XCTAssertEqual($0 as? IdentityService.RegistrationError, .userAlreadyRegistered)
        }
    }


    func test_registerUser_activatesBiometry() throws {
        try givenRegisteredUser()
        XCTAssertTrue(biometricService.didActivate)
    }

    func test_registerUser_storesEncryptedPassword() throws {
        let user = try givenRegisteredUser()
        XCTAssertEqual(user.password, encryptionService.encrypted(password))
    }

    func test_authenticateUser_whenEmptyPassword_thenThrowsError() {
        XCTAssertThrowsError(try service.authenticateUser(password: "")) {
            XCTAssertEqual($0 as? IdentityService.AuthenticationError, .emptyPassword)
        }
    }

    func test_authenticateUser_whenNotRegistered_thenReturnsNil() {
        XCTAssertNil(try service.authenticateUser(password: "some"))
    }

    func test_authenticateUser_whenCorrectPassword_thenSuccess() throws {
        let user = try givenRegisteredUser()
        XCTAssertEqual(try service.authenticateUser(password: password), user)
    }

    func test_authenticateUser_whenBiometrySuccess_thenSuccess() throws {
        let user = try givenRegisteredUser()
        biometricService.allowAuthentication()
        XCTAssertEqual(try service.authenticateUserBiometrically(), user)
    }

    func test_authenticateUser_whenBiometryFails_thenFails() throws {
        try givenRegisteredUser()
        biometricService.prohibitAuthentication()
        XCTAssertNil(try service.authenticateUserBiometrically())
    }

}

extension IdentityServiceTests {

    @discardableResult
    private func givenRegisteredUser() throws -> User {
        return try service.registerUser(password: password)
    }


    private func registerAgain() throws {
        _ = try identityService.registerUser(password: password)
    }

    // time-based authentication expiration

    // block & unblock, configuration

    // reset

}
