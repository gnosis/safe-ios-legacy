//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe
import IdentityAccessApplication

class MockAuthenticationService: AuthenticationApplicationService {

    private var userRegistered = false
    private var shouldThrowDuringRegistration = false
    private(set) var didRequestUserRegistration = false
    private var userAuthenticated = false
    private var authenticationAllowed = false
    private(set) var didRequestBiometricAuthentication = false
    private(set) var didRequestPasswordAuthentication = false
    private var enabledAuthenticationMethods = AuthenticationMethod.password
    private var possibleAuthenticationMethods: AuthenticationMethod = [.password, .touchID, .faceID]
    private var authenticationBlocked = false

    enum Error: Swift.Error { case error }

    func unregisterUser() {
        userRegistered = false
    }

    func prepareToThrowWhenRegisteringUser() {
        shouldThrowDuringRegistration = true
    }

    override var isUserRegistered: Bool {
        return userRegistered
    }

    override func registerUser(password: String, completion: (() -> Void)? = nil) throws {
        didRequestUserRegistration = true
        if shouldThrowDuringRegistration {
            throw Error.error
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

    override func isUserAuthenticated(session: String) -> Bool {
        return isUserRegistered && userAuthenticated && !isAuthenticationBlocked
    }

    override func authenticateUser(password: String?, completion: ((Bool) -> Void)? = nil) {
        didRequestBiometricAuthentication = password == nil
        didRequestPasswordAuthentication = !didRequestBiometricAuthentication
        userAuthenticated = authenticationAllowed && !authenticationBlocked
        completion?(userAuthenticated)
    }

    func makeBiometricAuthenticationImpossible() {
        possibleAuthenticationMethods = .password
    }

    func enableFaceIDSupport() {
        enabledAuthenticationMethods.insert(.faceID)
    }

    override func isAuthenticationMethodSupported(_ method: AuthenticationMethod) -> Bool {
        return enabledAuthenticationMethods.contains(method)
    }

    override func isAuthenticationMethodPossible(_ method: AuthenticationMethod) -> Bool {
        return !method.isDisjoint(with: possibleAuthenticationMethods)
    }

    func blockAuthentication() {
        authenticationBlocked = true
        makeBiometricAuthenticationImpossible()
    }

    override var isAuthenticationBlocked: Bool {
        return authenticationBlocked
    }
}
