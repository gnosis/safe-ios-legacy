//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public class User: Equatable {

    public let userID: UserID

    public init(id: UserID, password: String) {
        userID = id
    }

    public static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.userID == rhs.userID
    }
}

public struct UserID: Hashable {

    public var id: String

    public init(_ id: String) {
        self.id = id
    }

}
