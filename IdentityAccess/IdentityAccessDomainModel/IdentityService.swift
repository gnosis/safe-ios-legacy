//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public class IdentityService: Assertable {

    public enum Error: Swift.Error, Hashable {
        case emptyPassword
        case userAlreadyRegistered
    }

    public init() {}

    public func registerUser(password: String) throws -> User {
        let isRegistered = DomainRegistry.userRepository.primaryUser() != nil
        try IdentityService.assertArgument(!isRegistered, Error.userAlreadyRegistered)
        let encryptedPassword = DomainRegistry.encryptionService.encrypted(password)
        let user = try User(id: DomainRegistry.userRepository.nextId(), password: encryptedPassword)
        try DomainRegistry.userRepository.save(user)
        try DomainRegistry.biometricAuthenticationService.activate()
        return user
    }

    public func authenticateUser(password: String) throws -> User? {
        try IdentityService.assertArgument(!password.isEmpty, Error.emptyPassword)
        let encryptedPassword = DomainRegistry.encryptionService.encrypted(password)
        return DomainRegistry.userRepository.user(encryptedPassword: encryptedPassword)
    }

}
