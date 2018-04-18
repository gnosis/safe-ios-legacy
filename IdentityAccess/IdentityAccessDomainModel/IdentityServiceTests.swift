//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import IdentityAccessDomainModel

class IdentityServiceTests: DomainTestCase {

    let service = IdentityService()
    let password = "MyPassword1"
    let wrongPassword = "WrongPass"
    var gatekeeper: Gatekeeper!

    override func setUp() {
        super.setUp()
        var policy: AuthenticationPolicy!
        XCTAssertNoThrow(policy = try AuthenticationPolicy(sessionDuration: 2,
                                                           maxFailedAttempts: 2,
                                                           blockDuration: 1))
        XCTAssertNoThrow(
            gatekeeper = try Gatekeeper(id: gatekeeperRepository.nextId(),
                                        policy: policy))
        XCTAssertNoThrow(try gatekeeperRepository.save(gatekeeper))
    }

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
        XCTAssertThrowsError(try authenticateWithWrongPassword("")) {
            XCTAssertEqual($0 as? IdentityService.AuthenticationError, .emptyPassword)
        }
    }

    func test_authenticateUser_whenNotRegistered_thenReturnsNil() {
        XCTAssertNil(try authenticateWithCorrectPassword())
    }

    func test_authenticateUser_whenCorrectPassword_thenSuccess() throws {
        let user = try givenRegisteredUser()
        XCTAssertEqual(try authenticateWithCorrectPassword()?.userID, user.userID)
    }

    func test_authenticateUser_whenBiometrySuccess_thenSuccess() throws {
        let user = try givenRegisteredUser()
        biometricService.allowAuthentication()
        XCTAssertEqual(try authenticateWithBiometry()?.userID, user.userID)
    }

    func test_authenticateUser_whenBiometryFails_thenFails() throws {
        try givenRegisteredUser()
        biometricService.prohibitAuthentication()
        XCTAssertNil(try authenticateWithBiometry())
    }

    func test_whenAuthenticatedWithPassword_thenHasAccess() throws {
        try givenRegisteredUser()
        guard let user = try authenticateWithCorrectPassword() else {
            XCTFail("Expected to be authenticated")
            return
        }
        XCTAssertTrue(gatekeeper.hasAccess(session: user.sessionID, at: mockClockService.currentTime))
    }

    func test_whenAuthenticationFailed_thenHasNoAccess() throws {
        try givenRegisteredUser()
        let user = try authenticateWithWrongPassword()
        gatekeeper = gatekeeperRepository.gatekeeper()
        XCTAssertNil(user)
        XCTAssertTrue(gatekeeper.isAccessPossible(at: mockClockService.currentTime))
    }

    func test_whenAccessImpossible_thenNotAuthenticated() throws {
        try givenRegisteredUser()
        try blockAuthentication()
        gatekeeper = gatekeeperRepository.gatekeeper()
        XCTAssertFalse(gatekeeper.isAccessPossible(at: mockClockService.currentTime))
    }

    func test_whenAccessBlocked_andAuthenticatesWIthBiometry_thenHasNoAccess() throws {
        try givenRegisteredUser()
        try blockAuthentication()
        XCTAssertNil(try authenticateWithBiometry())
    }

    func test_createGatekeeper_createsOne() throws {
        let gatekeeper = try service.createGatekeeper(sessionDuration: 3,
                                                      maxFailedAttempts: 3,
                                                      blockDuration: 3)
        XCTAssertEqual(gatekeeperRepository.gatekeeper(), gatekeeper)
        XCTAssertEqual(gatekeeperRepository.gatekeeper()?.policy, gatekeeper.policy)
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

    private func blockAuthentication() throws {
        try authenticateWithWrongPassword()
        try authenticateWithWrongPassword()
    }

    @discardableResult
    private func authenticateWithWrongPassword(_ pass: String? = nil) throws -> UserDescriptor? {
        return try service.authenticateUser(password: pass ?? wrongPassword, at: mockClockService.currentTime)
    }

    @discardableResult
    private func authenticateWithCorrectPassword() throws -> UserDescriptor? {
        return try service.authenticateUser(password: password, at: mockClockService.currentTime)
    }

    @discardableResult
    private func authenticateWithBiometry() throws -> UserDescriptor? {
        return try service.authenticateUserBiometrically(at: mockClockService.currentTime)
    }

}
