//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import IdentityAccessDomainModel
import Common

/// The application service is a thin layer implementing application's use cases with objects from the domain model.
open class AuthenticationApplicationService {

    public enum Error: Swift.Error, Hashable {
        case emptyPassword
    }

    private var gatekeeperRepository: SingleGatekeeperRepository { return DomainRegistry.gatekeeperRepository }
    private var clock: Clock { return ApplicationServiceRegistry.clock }
    private var identityService: IdentityService { return DomainRegistry.identityService }
    private var userRepository: SingleUserRepository { return DomainRegistry.userRepository }
    private var biometricService: BiometricAuthenticationService {
        return DomainRegistry.biometricAuthenticationService
    }
    private var isAccessPossible: Bool {
        guard let gatekeeper = gatekeeperRepository.gatekeeper() else { return false }
        return gatekeeper.isAccessPossible(at: clock.currentTime)
    }

    public init() {}

    // MARK: - Queries

    /// Duration of a login block period. Login attempts will be blocked after `maxPasswordAttempts` number of
    /// failed password attempts. Default value is 15 seconds.
    open var blockedPeriodDuration: TimeInterval {
        guard let gatekeeper = gatekeeperRepository.gatekeeper() else { return 15 }
        return gatekeeper.policy.blockDuration
    }

    /// Maximum number of failed password attempts needed to block the login to the system.
    /// Default value is 5.
    open var maxPasswordAttempts: Int {
        guard let gatekeeper = gatekeeperRepository.gatekeeper() else { return 5 }
        return gatekeeper.policy.maxFailedAttempts
    }

    /// The time period during which password will not be requested if the app is running.
    open var sessionDuration: TimeInterval {
        guard let gatekeeper = gatekeeperRepository.gatekeeper() else { return 60 }
        return gatekeeper.policy.sessionDuration
    }

    /// True if the user authenticated successfully and session is not expired at this moment.
    open var isUserAuthenticated: Bool {
       return identityService.isUserAuthenticated(at: clock.currentTime)
    }

    /// True if the user has set the password
    open var isUserRegistered: Bool {
        return userRepository.primaryUser() != nil
    }

    /// True if authentication is blocked due to too many wrong password attempts.
    open var isAuthenticationBlocked: Bool {
        guard let gatekeeper = gatekeeperRepository.gatekeeper() else { return false }
        return !gatekeeper.isAccessPossible(at: clock.currentTime)
    }

    /// Queries the operating system and application capabilities to determine if the `method` of authentication
    /// supported.
    ///
    /// - Parameter method: The authentication type
    /// - Returns: True if the authentication `method` is supported.
    open func isAuthenticationMethodSupported(_ method: AuthenticationMethod) -> Bool {
        var supportedSet: AuthenticationMethod = .password
        if biometricService.biometryType == .touchID {
            supportedSet.insert(.touchID)
        }
        if biometricService.biometryType == .faceID {
            supportedSet.insert(.faceID)
        }
        return supportedSet.intersects(with: method)
    }

    /// Queries current state of the app (for example, session state) and the state of biometric service to
    /// determine if the authentication `method` can potentially succeed at this time. Returns false if
    /// access is blocked.
    ///
    /// - Parameter method: The authentication type
    /// - Returns: True if the authentication `method` can succeed.
    open func isAuthenticationMethodPossible(_ method: AuthenticationMethod) -> Bool {
        guard isAccessPossible else { return false }
        var possibleSet: AuthenticationMethod = .password
        if isAuthenticationMethodSupported(.faceID) && biometricService.isAuthenticationAvailable {
            possibleSet.insert(.faceID)
        }
        if isAuthenticationMethodSupported(.touchID) && biometricService.isAuthenticationAvailable {
            possibleSet.insert(.touchID)
        }
        return possibleSet.intersects(with: method)
    }

    // MARK: - Commands

    /// Attempts to authenticate a user with the `request`.
    ///
    /// - Parameter request: The authentication information to evaluate
    /// - Returns: authentication result.
    /// - Throws: May throw error if authentication failed due to internal issue.
    open func authenticateUser(_ request: AuthenticationRequest) throws -> AuthenticationResult {
        let time = clock.currentTime
        let user: UserID?
        if request.method == .password {
            user = try identityService.authenticateUser(password: request.password, at: time)
        } else if AuthenticationMethod.biometry.contains(request.method) {
            user = try identityService.authenticateUserBiometrically(at: time)
        } else {
            preconditionFailure("Invalid authentication method in request \(request)")
        }
        if let user = user {
            return .success(userID: user.id)
        } else if isAccessPossible {
            return .failure
        } else {
            return .blocked
        }
    }

    /// Sets user password. The password must be:
    ///     - At least 6 characters long
    ///     - Less than 100 characters long
    ///     - Has at least 1 uppercase letter
    ///     - Has at least 1 digit
    ///
    /// - Parameter password: The password to register.
    /// - Throws: Throws error if the user already registered, or password does not meet the
    /// strength criteria, or if there was an internal issue.
    open func registerUser(password: String) throws {
        _ = try DomainRegistry.identityService.registerUser(password: password)
    }

    /// Changes authenticated session duration.
    ///
    /// - Parameter duration: New duration of the authenticated session.
    /// - Throws: Throws error if duration is not positive or in case of an internal issue
    open func configureSession(_ duration: TimeInterval) throws {
        guard let gatekeeper = gatekeeperRepository.gatekeeper() else { return }
        try gatekeeper.changeSessionDuration(duration)
        try gatekeeperRepository.save(gatekeeper)
    }

    /// Changes number of maximum failed attempts before blocking authentication.
    ///
    /// - Parameter count: Number of attempts of password authentication.
    /// - Throws: Throws error if `count` is not positive or in case of an internal issue
    open func configureMaxPasswordAttempts(_ count: Int) throws {
        guard let gatekeeper = gatekeeperRepository.gatekeeper() else { return }
        try gatekeeper.changeMaxFailedAttempts(count)
        try gatekeeperRepository.save(gatekeeper)
    }

    /// Changes duration of the blocking period.
    ///
    /// - Parameter duration: new duration of the blocking period
    /// - Throws: Throws error if `duration` is negative or in case of an internal issue.
    open func configureBlockDuration(_ duration: TimeInterval) throws {
        guard let gatekeeper = gatekeeperRepository.gatekeeper() else { return }
        try gatekeeper.changeBlockDuration(duration)
        try gatekeeperRepository.save(gatekeeper)
    }

    /// Creates new authentication policy with provided parameters
    ///
    /// - Parameters:
    ///   - sessionDuration: duration of the authenticated session
    ///   - maxPasswordAttempts: number of attempts before authentication is blocked
    ///   - blockedPeriodDuration: duration fo the blocked authentication period
    /// - Throws: Throws error if the values are invalid or in case of an internal error.
    open func createAuthenticationPolicy(sessionDuration: TimeInterval,
                                         maxPasswordAttempts: Int,
                                         blockedPeriodDuration: TimeInterval) throws {
        try identityService.createGatekeeper(sessionDuration: sessionDuration,
                                             maxFailedAttempts: maxPasswordAttempts,
                                             blockDuration: blockedPeriodDuration)
    }

    /// Deletes registered user and any authentication policies created earlier
    ///
    /// - Throws: Throws error if there was an internal error.
    open func reset() throws {
        if let user = userRepository.primaryUser() {
            try userRepository.remove(user)
        }
        if let gatekeeper = gatekeeperRepository.gatekeeper() {
            gatekeeper.reset()
            try DomainRegistry.gatekeeperRepository.save(gatekeeper)
        }
    }

}
