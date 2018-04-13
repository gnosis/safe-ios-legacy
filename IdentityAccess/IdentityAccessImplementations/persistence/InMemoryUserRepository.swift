//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import IdentityAccessDomainModel

public class InMemoryUserRepository: UserRepository {

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
        do {
            return try UserID(UUID().uuidString)
        } catch let e {
            preconditionFailure("Failed to generate next user ID: \(e)")
        }
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
