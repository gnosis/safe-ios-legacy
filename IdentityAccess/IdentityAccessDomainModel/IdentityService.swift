//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public class IdentityService: Assertable {

    public enum RegistrationError: Error, Hashable {
        case userAlreadyRegistered
    }

    public enum AuthenticationError: Error, Hashable {
        case emptyPassword
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
    private var sessionRepository: SessionRepository {
        return DomainRegistry.sessionRepository
    }
    private var clockService: Clock {
        return DomainRegistry.clock
    }

    public init() {}

    public func registerUser(password: String) throws -> User {
        let isRegistered = userRepository.primaryUser() != nil
        try assertArgument(!isRegistered, RegistrationError.userAlreadyRegistered)
        let encryptedPassword = encryptionService.encrypted(password)
        let user = try User(id: userRepository.nextId(), password: encryptedPassword)
        try userRepository.save(user)
        try biometricService.activate()
        return user
    }

    // when user signs in, they can use their role
    // after some period of inactivity their authentication expires
    // activity period is extended when hasRole() checks are performed
    // some roles would require password to be supplied

    // after registration, the roles could be provisioned by the client and assigned to the user
    // roles can have authenticated session scope or one-time usage scope.
    // for 1-time roles, the password must be supplied

    // on the client side, when some operation has protected access,
    // the client would ask identity & access context whether the primary user has some role.

    public func configure() {}

    @discardableResult
    public func authenticateUser(password: String) throws -> User? {
        try assertArgument(!password.isEmpty, AuthenticationError.emptyPassword)
        let encryptedPassword = encryptionService.encrypted(password)
        guard let user = userRepository.user(encryptedPassword: encryptedPassword) else {
            return nil
        }
        try startSession()
        return user
    }

    private func startSession() throws {
        let duration: TimeInterval = sessionRepository.sessionConfiguration()?.duration ?? 60
        let session = try XSession(id: sessionRepository.nextId(), durationInSeconds: duration)
        try session.start(clockService.currentTime)
        try sessionRepository.save(session)
    }

    @discardableResult
    public func authenticateUserBiometrically() throws -> User? {
        let isSuccess = biometricService.authenticate()
        guard isSuccess else { return nil }
        guard let user = userRepository.primaryUser() else { return nil }
        try startSession()
        return user
    }

}
