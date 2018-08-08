//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import IdentityAccessDomainModel

/// Stores user entity in memory.
public class InMemoryUserRepository: SingleUserRepository {

    private var storedUser: User?

    public var isEmpty: Bool { return primaryUser() == nil }

    public enum Error: Swift.Error, Hashable {
        case primaryUserAlreadyExists
        case userNotFound
    }

    public init() {}

    public func save(_ user: User) throws {
        try assertEmptyOrUserExists(user, otherwise: .primaryUserAlreadyExists)
        storedUser = user
    }

    public func remove(_ user: User) throws {
        try assertEmptyOrUserExists(user, otherwise: .userNotFound)
        storedUser = nil
    }

    public func primaryUser() -> User? {
        return storedUser
    }

    public func nextId() -> UserID {
        return UserID()
    }

    func assertEmptyOrUserExists(_ user: User, otherwise error: Error) throws {
        if !isEmpty && user != storedUser {
            throw error
        }
    }

    public func user(encryptedPassword: String) -> User? {
        return primaryUser()?.password == encryptedPassword ? primaryUser() : nil
    }

}
