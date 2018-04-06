//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

// user registered when password is set on account
// authentication sets session to active // or creates active session
// when session expires, authentication invalidates
//precondition(authenticationService.isUserRegistered() || !authenticationService.isUserAuthenticated(),
//             "User cannot be unregistered and authenticated at the same time")
// when registering, clean ups data
// when registering, activates biometric

class MockAuthenticationService: AuthenticationApplicationService {

    private var userRegistered = false
    private var shouldThrowDuringRegistration = false
    private(set) var didRequestUserRegistration = false
    private var userAuthenticated = false
    private var authenticationAllowed = false
    private(set) var didRequestBiometricAuthentication = false
    private(set) var didRequestPasswordAuthentication = false
    private var biometricAuthenticationPossible = true
    private var enabledAuthenticationMethods = Set<AuthenticationMethod>([AuthenticationMethod.password])
    private var authenticationBlocked = false

    init() {
        super.init(account: MockAccount())
    }

    func unregisterUser() {
        userRegistered = false
    }

    func prepareToThrowWhenRegisteringUser() {
        shouldThrowDuringRegistration = true
    }

    override func isUserRegistered() -> Bool {
        return userRegistered
    }

    override func registerUser(password: String, completion: (() -> Void)? = nil) throws {
        didRequestUserRegistration = true
        if shouldThrowDuringRegistration {
            throw MockAccount.Error.error
        }
        userRegistered = true
        completion?()
    }

    func invalidateAuthentication() {
        authenticationAllowed = false
        userAuthenticated = false
    }

    func allowAuthentication() {
        authenticationAllowed = true
    }

    override func isUserAuthenticated() -> Bool {
        return isUserRegistered() && userAuthenticated && !isAuthenticationBlocked()
    }

    override func authenticateUser(password: String?, completion: ((Bool) -> Void)? = nil) {
        didRequestBiometricAuthentication = password == nil
        didRequestPasswordAuthentication = !didRequestBiometricAuthentication
        userAuthenticated = authenticationAllowed && !authenticationBlocked
        completion?(userAuthenticated)
    }

    func makeBiometricAuthenticationImpossible() {
        biometricAuthenticationPossible = false
    }

    override func isBiometricAuthenticationPossible() -> Bool {
        return biometricAuthenticationPossible
    }

    func enableFaceIDSupport() {
        enabledAuthenticationMethods.insert(.faceID)
    }

    override func isAuthenticationMethodSupported(_ method: AuthenticationMethod) -> Bool {
        return enabledAuthenticationMethods.contains(method)
    }

    func blockAuthentication() {
        authenticationBlocked = true
        makeBiometricAuthenticationImpossible()
    }

    override func isAuthenticationBlocked() -> Bool {
        return authenticationBlocked
    }
}
