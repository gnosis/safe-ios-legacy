//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

/// Represents persisted user entity
public protocol SingleUserRepository {

    /// Saves user's state.
    ///
    /// - Parameter user: user entity
    /// - Throws: error in case persisting fails
    func save(_ user: User) throws

    /// Removes user from repository.
    ///
    /// - Parameter user: existing user
    /// - Throws: error if removing fails
    func remove(_ user: User) throws

    /// Returns single user, if it exists
    ///
    /// - Returns: user, if any
    func primaryUser() -> User?

    /// Generates new user id
    ///
    /// - Returns: new user id
    func nextId() -> UserID

    /// Finds user by encrypted password
    ///
    /// - Parameter encryptedPassword: encrypted/hashed password to find user.
    /// - Returns: found user, if passwords match, nil otherwise or nil if no user exists.
    func user(encryptedPassword: String) -> User?

}
