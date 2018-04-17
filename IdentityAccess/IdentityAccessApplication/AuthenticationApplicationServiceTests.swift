//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import IdentityAccessApplication
import IdentityAccessDomainModel
import IdentityAccessImplementations

class AuthenticationApplicationServiceTests: ApplicationServiceTestCase {

    let password = "MyPassword1"

    override func setUp() {
        super.setUp()
        XCTAssertNoThrow(try authenticationService.registerUser(password: password))
    }

    func test_registerUser_createsUser() throws {
        XCTAssertNotNil(userRepository.primaryUser())
    }

    func test_authenticateUser_whenNotRegisteredThenFails() throws {
        try authenticationService.reset()
        let result = try authenticationService.authenticateUser(.password(password))
        XCTAssertEqual(result.status, .failure)
    }

    func test_authenticateUser_whenPasswordCorrect_thenSuccess() throws {
        let result = try authenticationService.authenticateUser(.password(password))
        XCTAssertEqual(result.status, .success)
    }

    func test_authenticateUser_whenBiometryAllows_thenSuccess() throws {
        biometricService.allowAuthentication()
        let result = try authenticationService.authenticateUser(.biometry())
        XCTAssertEqual(result.status, .success)
    }

    private func blockAuthenticationThroughBiometry() throws {
        biometricService.prohibitAuthentication()
        _ = try authenticationService.authenticateUser(.biometry())
        _ = try authenticationService.authenticateUser(.biometry())
    }

    func test_authenticateUser_whenBlocked_thenStatusBlocked() throws {
        try blockAuthenticationThroughBiometry()
        let result = try authenticationService.authenticateUser(.biometry())
        XCTAssertEqual(result.status, .blocked)
    }

    func test_isAuthenticationMethodSupported() {
        XCTAssertTrue(authenticationService.isAuthenticationMethodSupported(.password))
        biometricService.biometryType = .faceID
        XCTAssertTrue(authenticationService.isAuthenticationMethodSupported(.biometry))
        XCTAssertTrue(authenticationService.isAuthenticationMethodSupported(.faceID))
        biometricService.biometryType = .touchID
        XCTAssertTrue(authenticationService.isAuthenticationMethodSupported(.biometry))
        XCTAssertTrue(authenticationService.isAuthenticationMethodSupported(.touchID))
        XCTAssertFalse(authenticationService.isAuthenticationMethodSupported([]))
    }

    func test_isAuthenticationMethodPossible_whenNotBlocked_thenOk() {
        XCTAssertTrue(authenticationService.isAuthenticationMethodPossible(.password))
    }

    func test_isAuthenticationMethodPossible_whenBlocked_thenNotPossible() throws {
        biometricService.biometryType = .faceID
        try blockAuthenticationThroughBiometry()
        XCTAssertFalse(authenticationService.isAuthenticationMethodPossible([.password, .touchID, .faceID]))
    }

    func test_isAuthenticationMethodPossible_biometry() {
        biometricService.isAuthenticationAvailable = true
        biometricService.biometryType = .faceID
        XCTAssertTrue(authenticationService.isAuthenticationMethodPossible(.faceID))
        biometricService.biometryType = .touchID
        XCTAssertTrue(authenticationService.isAuthenticationMethodPossible(.touchID))
        biometricService.isAuthenticationAvailable = false
        XCTAssertFalse(authenticationService.isAuthenticationMethodPossible(.biometry))
        XCTAssertFalse(authenticationService.isAuthenticationMethodPossible(.faceID))
        XCTAssertFalse(authenticationService.isAuthenticationMethodPossible(.touchID))
    }

    func test_sessionDuration() throws {
        try authenticationService.configureSession(15)
        XCTAssertEqual(authenticationService.sessionDuration, 15)
    }

    func test_maxPasswordAttempts() throws {
        try authenticationService.configureMaxPasswordAttempts(15)
        XCTAssertEqual(authenticationService.maxPasswordAttempts, 15)
    }

    func test_blockDuration() throws {
        try authenticationService.configureBlockDuration(15)
        XCTAssertEqual(authenticationService.blockedPeriodDuration, 15)
    }

    func test_isAuthenticated_whenNotRegistered_thenFails() throws {
        guard let session = try authenticationService.authenticateUser(.password(password)).sessionID else {
            XCTFail("Expected to authenticate")
            return
        }
        try authenticationService.reset()
        XCTAssertFalse(authenticationService.isUserAuthenticated(session: session))
    }

    func test_isAuthenticated_whenNotAuthenticated_thenFails() {
        XCTAssertFalse(authenticationService.isUserAuthenticated(session: ""))
    }

    func test_isAuthenticated_whenSessionExpired_thenFails() throws {
        biometricService.allowAuthentication()
        guard let session = try authenticationService.authenticateUser(.biometry()).sessionID else {
            XCTFail("Expected to authenticate")
            return
        }
        clockService.currentTime =
            clockService.currentTime.addingTimeInterval(authenticationService.sessionDuration + 1)
        XCTAssertFalse(authenticationService.isUserAuthenticated(session: session))
    }

    func test_isBiometryPossible_whenBlocked_thenFails() throws {
        try blockAuthenticationThroughBiometry()
        XCTAssertFalse(authenticationService.isAuthenticationMethodPossible(.biometry))
    }

    func test_isBiometryPossible_whenNotAvailable_thenFails() {
        biometricService.isAuthenticationAvailable = false
        XCTAssertFalse(authenticationService.isAuthenticationMethodPossible(.biometry))
    }

    func test_isBiometryPossible_whenSupported_thenSuccess() {
        biometricService.isAuthenticationAvailable = true
        biometricService.biometryType = .touchID
        XCTAssertTrue(authenticationService.isAuthenticationMethodPossible(.biometry))
    }

    func test_whenProvisioningGatekeeper_thenChangesRepository() throws {
        if let gatekeeper = gatekeeperRepository.gatekeeper() {
            try gatekeeperRepository.remove(gatekeeper)
        }
        try authenticationService.provisionAuthenticationPolicy(sessionDuration: 1,
                                                                maxPasswordAttempts: 1,
                                                                blockedPeriodDuration: 1)
        XCTAssertEqual(authenticationService.sessionDuration, 1)
        XCTAssertEqual(authenticationService.maxPasswordAttempts, 1)
        XCTAssertEqual(authenticationService.blockedPeriodDuration, 1)
    }

}
