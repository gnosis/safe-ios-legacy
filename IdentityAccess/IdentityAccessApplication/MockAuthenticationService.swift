//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public class MockAuthenticationService: AuthenticationApplicationService {

    private var userRegistered = false
    private var shouldThrowDuringRegistration = false
    public private(set) var didRequestUserRegistration = false
    private var userAuthenticated = false
    private var authenticationAllowed = false
    public private(set) var didRequestBiometricAuthentication = false
    public private(set) var didRequestPasswordAuthentication = false
    private var enabledAuthenticationMethods = AuthenticationMethod.password
    private var possibleAuthenticationMethods: AuthenticationMethod = [.password, .touchID, .faceID]
    private var authenticationBlocked = false

    public enum Error: Swift.Error { case error }

    public func unregisterUser() {
        userRegistered = false
    }

    public func prepareToThrowWhenRegisteringUser() {
        shouldThrowDuringRegistration = true
    }

    public override var isUserRegistered: Bool {
        return userRegistered
    }

    public override func registerUser(password: String) throws {
        didRequestUserRegistration = true
        if shouldThrowDuringRegistration {
            throw Error.error
        }
        userRegistered = true
    }

    public func invalidateAuthentication() {
        authenticationAllowed = false
        userAuthenticated = false
    }

    public func allowAuthentication() {
        authenticationAllowed = true
    }

    public override var isUserAuthenticated: Bool {
        return isUserRegistered && userAuthenticated && !isAuthenticationBlocked
    }

    public override func authenticateUser(_ request: AuthenticationRequest) throws -> AuthenticationResult {
        didRequestBiometricAuthentication = !request.method.isDisjoint(with: .biometry)
        didRequestPasswordAuthentication = request.method.contains(.password)
        userAuthenticated = authenticationAllowed && !authenticationBlocked
        if authenticationBlocked {
            return .blocked
        } else {
            return userAuthenticated ? .success(userID: "userID") : .failure
        }
    }

    public func makeBiometricAuthenticationImpossible() {
        possibleAuthenticationMethods = .password
    }

    public func enableFaceIDSupport() {
        enabledAuthenticationMethods.insert(.faceID)
    }

    public override func isAuthenticationMethodSupported(_ method: AuthenticationMethod) -> Bool {
        return !method.isDisjoint(with: enabledAuthenticationMethods)
    }

    public override func isAuthenticationMethodPossible(_ method: AuthenticationMethod) -> Bool {
        return !method.isDisjoint(with: possibleAuthenticationMethods)
    }

    public func blockAuthentication() {
        authenticationBlocked = true
        makeBiometricAuthenticationImpossible()
    }

    public override var isAuthenticationBlocked: Bool {
        return authenticationBlocked
    }
}
