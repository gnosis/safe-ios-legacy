//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import IdentityAccessDomainModel

class IdentityServiceTests: DomainTestCase {

    let password = "MyPassword1"
    let wrongPassword = "WrongPass"
    var gatekeeper: Gatekeeper!

    override func setUp() {
        super.setUp()
        var policy: AuthenticationPolicy!
        XCTAssertNoThrow(policy = try AuthenticationPolicy(sessionDuration: 2,
                                                           maxFailedAttempts: 2,
                                                           blockDuration: 1))
        gatekeeper = Gatekeeper(id: gatekeeperRepository.nextId(), policy: policy)
        gatekeeperRepository.save(gatekeeper)
    }

    // MARK: - Register user

    func test_registerUser_savesInRepository() throws {
        let user = try givenRegisteredUser()
        XCTAssertEqual(userRepository.primaryUser()?.id, user)
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
        try givenRegisteredUser()
        let user = userRepository.primaryUser()
        XCTAssertEqual(user?.password, encryptionService.encrypted(password))
    }

    func test_create_passwordNotEmpty() {
        XCTAssertThrowsError(try createUser(password: "")) {
            self.assertError($0, .emptyPassword)
        }
    }

    func test_create_passwordNSymbols() {
        let short = String(repeating: "1", count: 5)
        let long = String(repeating: "qwe123qwe", count: 101)
        XCTAssertThrowsError(try createUser(password: short)) {
            self.assertError($0, .passwordTooShort)
        }
        XCTAssertNoThrow(try createUser(password: long))
    }

    func test_create_passwordCapitalLetter() {
        XCTAssertThrowsError(try createUser(password: "123456")) {
            self.assertError($0, .passwordMissingLetter)
        }
    }

    func test_create_digit() {
        XCTAssertThrowsError(try createUser(password: "abcabC")) {
            self.assertError($0, .passwordMissingDigit)
        }
    }

    func test_whenUpdatingPrimaryUserPassword_thenUpdatesIt() throws {
        try givenRegisteredUser()
        let newPassword = "MyPassword2"
        try identityService.updatePrimaryUserPassword(with: newPassword)
        XCTAssertEqual(userRepository.primaryUser()!.password, encryptionService.encrypted(newPassword))
    }

    func test_whenUpdatingPrimaryUserWithInvalidPassword_thenThrows() throws {
        try givenRegisteredUser()
        XCTAssertThrowsError(try identityService.updatePrimaryUserPassword(with: "abc")) {
            self.assertError($0, .passwordTooShort)
        }
    }

    func test_whenUpdatingPrimaryUserThatDoesNotExist_thenThrows() throws {
        XCTAssertThrowsError(try identityService.updatePrimaryUserPassword(with: password)) {
            self.assertUpdatePasswordError($0, .primaryUserNotFound)
        }
    }

    // MARK: - Authenticate user

    func test_authenticateUser_whenEmptyPassword_thenInvalid() throws {
        let result = try authenticateWithWrongPassword("")
        XCTAssertNil(result)
    }

    func test_authenticateUser_whenNotRegistered_thenReturnsNil() {
        XCTAssertNil(try authenticateWithCorrectPassword())
    }

    func test_authenticateUser_whenCorrectPassword_thenSuccess() throws {
        let user = try givenRegisteredUser()
        XCTAssertEqual(try authenticateWithCorrectPassword(), user)
    }

    func test_authenticateUser_whenBiometrySuccess_thenSuccess() throws {
        let user = try givenRegisteredUser()
        biometricService.allowAuthentication()
        XCTAssertEqual(try authenticateWithBiometry(), user)
    }

    func test_authenticateUser_whenBiometryFails_thenFails() throws {
        try givenRegisteredUser()
        biometricService.prohibitAuthentication()
        XCTAssertNil(try authenticateWithBiometry())
    }

    func test_whenAuthenticatedWithPassword_thenHasAccess() throws {
        try givenRegisteredUser()
        try authenticateWithCorrectPassword()
        XCTAssertTrue(identityService.isUserAuthenticated(at: mockClockService.currentTime))
    }

    func test_whenNotRegistered_thenNotAuthenticated() {
        XCTAssertFalse(identityService.isUserAuthenticated(at: mockClockService.currentTime))
    }

    func test_whenNoGatekeeper_thenNotAuthenticated() throws {
        gatekeeperRepository.remove(gatekeeper)
        XCTAssertFalse(identityService.isUserAuthenticated(at: mockClockService.currentTime))
    }

    func test_whenDidNotAuthenticate_thenNotAuthenticated() throws {
        try givenRegisteredUser()
        XCTAssertFalse(identityService.isUserAuthenticated(at: mockClockService.currentTime))
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

    // MARK: - Gatekeeper

    func test_createGatekeeper_createsOne() throws {
        let gatekeeper = try identityService.createGatekeeper(sessionDuration: 3,
                                                              maxFailedAttempts: 3,
                                                              blockDuration: 3)
        XCTAssertEqual(gatekeeperRepository.gatekeeper(), gatekeeper)
        XCTAssertEqual(gatekeeperRepository.gatekeeper()?.policy, gatekeeper.policy)
    }

}

extension IdentityServiceTests {

    private func createUser(password: String) throws {
        _ = try identityService.registerUser(password: password)
    }

    private func assertError(_ error: Error, _ expected: IdentityService.RegistrationError) {
        XCTAssertEqual(error as? IdentityService.RegistrationError, expected)
    }

    private func assertUpdatePasswordError(_ error: Error, _ expected: IdentityService.UpdatePasswordError) {
        XCTAssertEqual(error as? IdentityService.UpdatePasswordError, expected)
    }

    @discardableResult
    private func givenRegisteredUser() throws -> UserID {
        return try identityService.registerUser(password: password)
    }

    private func registerAgain() throws {
        _ = try identityService.registerUser(password: password)
    }

    private func blockAuthentication() throws {
        try authenticateWithWrongPassword()
        try authenticateWithWrongPassword()
    }

    @discardableResult
    private func authenticateWithWrongPassword(_ pass: String? = nil) throws -> UserID? {
        return try identityService.authenticateUser(password: pass ?? wrongPassword, at: mockClockService.currentTime)
    }

    @discardableResult
    private func authenticateWithCorrectPassword() throws -> UserID? {
        return try identityService.authenticateUser(password: password, at: mockClockService.currentTime)
    }

    @discardableResult
    private func authenticateWithBiometry() throws -> UserID? {
        return try identityService.authenticateUserBiometrically(at: mockClockService.currentTime)
    }

}
