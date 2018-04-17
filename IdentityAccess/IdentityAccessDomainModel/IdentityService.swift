//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public struct UserDescriptor {
    public let userID: UserID
    public let sessionID: SessionID
}

public class IdentityService: Assertable {

    public enum RegistrationError: Error, Hashable {
        case userAlreadyRegistered
    }

    public enum AuthenticationError: Error, Hashable {
        case emptyPassword
        case gatekeeperNotFound
    }

    private var userRepository: UserRepository {
        return DomainRegistry.userRepository
    }
    private var encryptionService: EncryptionServiceProtocol {
        return DomainRegistry.encryptionService
    }
    private var biometricService: BiometricAuthenticationService {
        return DomainRegistry.biometricAuthenticationService
    }
    private var gatekeeperRepository: GatekeeperRepository {
        return DomainRegistry.gatekeeperRepository
    }
    private var clockService: Clock {
        return DomainRegistry.clock
    }

    public init() {}

    @discardableResult
    public func provisionGatekeeper(sessionDuration: TimeInterval,
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

    public func registerUser(password: String) throws -> User {
        let isRegistered = userRepository.primaryUser() != nil
        try assertArgument(!isRegistered, RegistrationError.userAlreadyRegistered)
        let encryptedPassword = encryptionService.encrypted(password)
        let user = try User(id: userRepository.nextId(), password: encryptedPassword)
        try userRepository.save(user)
        try biometricService.activate()
        return user
    }

    @discardableResult
    public func authenticateUser(password: String) throws -> UserDescriptor? {
        return try authenticateWith {
            try assertArgument(!password.isEmpty, AuthenticationError.emptyPassword)
            let encryptedPassword = encryptionService.encrypted(password)
            let user = userRepository.user(encryptedPassword: encryptedPassword)
            return user
        }
    }

    private func authenticateWith(_ authenticate: () throws -> User?) throws -> UserDescriptor? {
        guard let gatekeeper = gatekeeperRepository.gatekeeper() else {
            throw AuthenticationError.gatekeeperNotFound
        }
        let time = clockService.currentTime
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
        return UserDescriptor(userID: user.userID, sessionID: session)
    }

    @discardableResult
    public func authenticateUserBiometrically() throws -> UserDescriptor? {
        return try authenticateWith {
            guard biometricService.authenticate() else { return nil }
            return userRepository.primaryUser()
        }
    }

}
