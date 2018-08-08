//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

/// ID of a user entity
public class UserID: BaseID {}

/// Represents system's user identity, identified by password. User can be associated with a session by session id.
public class User: IdentifiableEntity<UserID> {

    public private(set) var password: String = ""
    public private(set) var sessionID: SessionID?

    public static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }

    /// Creates new user with id and password. Password must be in encrypted/hashed form.
    ///
    /// - Parameters:
    ///   - id: user id
    ///   - password: encrypted passwrod
    public init(id: UserID, password: String) {
        super.init(id: id)
        changePassword(old: "", new: password)
    }

    /// Changes password to new one
    ///
    /// - Parameters:
    ///   - old: old password
    ///   - password: new password
    func changePassword(old: String, new password: String) {
        self.password = password
    }

    /// Attaches session id to the user
    ///
    /// - Parameter id: session id
    public func attachSession(id: SessionID) {
        sessionID = id
    }

}
