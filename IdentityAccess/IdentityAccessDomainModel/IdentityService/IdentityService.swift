//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

/// Domain service that handles registration and authentication tasks.
public class IdentityService: Assertable {

    /// Error occurred during registration
    ///
    /// - userAlreadyRegistered: user already exists
    /// - emptyPassword: password was empty
    /// - passwordTooShort: password is too short
    /// - passwordTooLong: password is too long
    /// - passwordMissingCapitalLetter: password needs at least one capital letter
    /// - passwordMissingDigit: password needs at least one digit
    public enum RegistrationError: Error, Hashable {
        case userAlreadyRegistered
        case emptyPassword
        case passwordTooShort
        case passwordTooLong
        case passwordMissingCapitalLetter
        case passwordMissingDigit
    }

    /// Error occurred during notification
    ///
    /// - gatekeeperNotFound: No gatekeeper found. This is critical configuration error.
    public enum AuthenticationError: Error, Hashable {
        case gatekeeperNotFound
    }

    private var userRepository: SingleUserRepository {
        return DomainRegistry.userRepository
    }
    private var encryptionService: EncryptionService {
        return DomainRegistry.encryptionService
    }
    private var biometricService: BiometricAuthenticationService {
        return DomainRegistry.biometricAuthenticationService
    }
    private var gatekeeperRepository: SingleGatekeeperRepository {
        return DomainRegistry.gatekeeperRepository
    }

    /// Creates new identity service.
    public init() {}

    /// Checks wheter user is authenticated.
    ///
    /// - Parameter time: current time
    /// - Returns: true if authenticated, false otherwise.
    public func isUserAuthenticated(at time: Date) -> Bool {
        guard let gatekeeper = gatekeeperRepository.gatekeeper() else { return false }
        guard let sessionID = userRepository.primaryUser()?.sessionID else { return false }
        return gatekeeper.hasAccess(session: sessionID, at: time)
    }

    /// Creates new Gatekeeper with provided authentication parameters
    ///
    /// - Parameters:
    ///   - sessionDuration: duration of authenticated session
    ///   - maxFailedAttempts: maximum number of failed attempts to authenticate
    ///   - blockDuration: duration of blocked authentication when maximum attempts reached.
    /// - Returns: new Gatekeeper
    /// - Throws: error if supplied values were invalid
    @discardableResult
    public func createGatekeeper(sessionDuration: TimeInterval,
                                 maxFailedAttempts: Int,
                                 blockDuration: TimeInterval) throws -> Gatekeeper {
        let policy = try AuthenticationPolicy(sessionDuration: sessionDuration,
                                              maxFailedAttempts: maxFailedAttempts,
                                              blockDuration: blockDuration)
        let gatekeeper = Gatekeeper(id: gatekeeperRepository.nextId(), policy: policy)
        try gatekeeperRepository.save(gatekeeper)
        return gatekeeper
    }

    /// Registers user. No user must be registered beforehand,
    /// otherwise method throws `IdentityService.RegistrationError.userAlreadyRegistered`.
    ///
    /// - Parameter password: Password must not be empty, be at least 6 and at most 100 characters long,
    ///     contain at least 1 capital letter and at least 1 digit.
    /// - Returns: registered user's id
    /// - Throws: error if user already registered or password error if password is invalid.
    public func registerUser(password: String) throws -> UserID {
        let isRegistered = userRepository.primaryUser() != nil
        try assertArgument(!isRegistered, RegistrationError.userAlreadyRegistered)
        try validatePlaintextPassword(password)
        let encryptedPassword = encryptionService.encrypted(password)
        let user = User(id: userRepository.nextId(), password: encryptedPassword)
        try userRepository.save(user)
        try biometricService.activate()
        return user.id
    }

    private func validatePlaintextPassword(_ password: String) throws {
        try assertArgument(!password.isEmpty, RegistrationError.emptyPassword)
        try assertArgument(password.count >= 6, RegistrationError.passwordTooShort)
        try assertArgument(password.count <= 100, RegistrationError.passwordTooLong)
        try assertArgument(password.hasUppercaseLetter, RegistrationError.passwordMissingCapitalLetter)
        try assertArgument(password.hasDecimalDigit, RegistrationError.passwordMissingDigit)
    }

    /// Attempts to authenticate user using password.
    ///
    /// - Parameters:
    ///   - password: password to authenticate with
    ///   - time: current time
    /// - Returns: user id if password was correct and authentication is not blocked
    /// - Throws: error in case of configuration issue or persistence issue.
    @discardableResult
    public func authenticateUser(password: String, at time: Date) throws -> UserID? {
        return try authenticate(at: time) {
            let encryptedPassword = encryptionService.encrypted(password)
            let user = userRepository.user(encryptedPassword: encryptedPassword)
            return user
        }
    }

    private func authenticate(at time: Date, _ authenticate: () throws -> User?) throws -> UserID? {
        guard let gatekeeper = gatekeeperRepository.gatekeeper() else {
            throw AuthenticationError.gatekeeperNotFound
        }
        guard gatekeeper.isAccessPossible(at: time) else {
            return nil
        }
        guard let user = try authenticate() else {
            gatekeeper.denyAccess(at: time)
            try gatekeeperRepository.save(gatekeeper)
            return nil
        }
        let session = try gatekeeper.allowAccess(at: time)
        try gatekeeperRepository.save(gatekeeper)
        user.attachSession(id: session)
        try userRepository.save(user)
        return user.id
    }

    /// Attempts to authenticate user using biometry.
    ///
    /// - Parameter time: current time
    /// - Returns: user id if authentication successful.
    /// - Throws: error in case of configuration or persistance issue.
    @discardableResult
    public func authenticateUserBiometrically(at time: Date) throws -> UserID? {
        return try authenticate(at: time) {
            guard biometricService.authenticate() else { return nil }
            return userRepository.primaryUser()
        }
    }

}
