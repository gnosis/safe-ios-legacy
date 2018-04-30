//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public class IdentityService: Assertable {

    public enum RegistrationError: Error, Hashable {
        case userAlreadyRegistered
        case emptyPassword
        case passwordTooShort
        case passwordTooLong
        case passwordMissingCapitalLetter
        case passwordMissingDigit
    }

    public enum AuthenticationError: Error, Hashable {
        case emptyPassword
        case gatekeeperNotFound
    }

    private var userRepository: SingleUserRepository {
        return DomainRegistry.userRepository
    }
    private var encryptionService: EncryptionServiceProtocol {
        return DomainRegistry.encryptionService
    }
    private var biometricService: BiometricAuthenticationService {
        return DomainRegistry.biometricAuthenticationService
    }
    private var gatekeeperRepository: SingleGatekeeperRepository {
        return DomainRegistry.gatekeeperRepository
    }

    public init() {}

    public func isUserAuthenticated(at time: Date) -> Bool {
        guard let gatekeeper = gatekeeperRepository.gatekeeper() else { return false }
        guard let sessionID = userRepository.primaryUser()?.sessionID else { return false }
        return gatekeeper.hasAccess(session: sessionID, at: time)
    }

    @discardableResult
    public func createGatekeeper(sessionDuration: TimeInterval,
                                 maxFailedAttempts: Int,
                                 blockDuration: TimeInterval) throws -> Gatekeeper {
        let policy = try AuthenticationPolicy(sessionDuration: sessionDuration,
                                              maxFailedAttempts: maxFailedAttempts,
                                              blockDuration: blockDuration)
        let gatekeeper = try Gatekeeper(id: gatekeeperRepository.nextId(),
                                        policy: policy)
        try gatekeeperRepository.save(gatekeeper)
        return gatekeeper
    }

    public func registerUser(password: String) throws -> UserID {
        let isRegistered = userRepository.primaryUser() != nil
        try assertArgument(!isRegistered, RegistrationError.userAlreadyRegistered)
        try validatePlaintextPassword(password)
        let encryptedPassword = encryptionService.encrypted(password)
        let user = try User(id: userRepository.nextId(), password: encryptedPassword)
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

    @discardableResult
    public func authenticateUser(password: String, at time: Date) throws -> UserID? {
        return try authenticate(at: time) {
            try assertArgument(!password.isEmpty, AuthenticationError.emptyPassword)
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

    @discardableResult
    public func authenticateUserBiometrically(at time: Date) throws -> UserID? {
        return try authenticate(at: time) {
            guard biometricService.authenticate() else { return nil }
            return userRepository.primaryUser()
        }
    }

}
