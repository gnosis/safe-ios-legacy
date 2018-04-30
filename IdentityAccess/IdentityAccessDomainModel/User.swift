//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public class UserID: BaseID {}

public class User: IdentifiableEntity<UserID> {

    public private(set) var password: String = ""
    public private(set) var sessionID: SessionID?

    public static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }

    public init(id: UserID, password: String) throws {
        super.init(id: id)
        try changePassword(old: "", new: password)
    }

    func changePassword(old: String, new password: String) throws {
        self.password = password
    }

    public func attachSession(id: SessionID) {
        sessionID = id
    }

}
