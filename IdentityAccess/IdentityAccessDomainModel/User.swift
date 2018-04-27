//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public class UserID: BaseID {}

public class User: IdentifiableEntity<UserID> {

    public private(set) var password: String = ""
    public private(set) var sessionID: SessionID?

    public enum Error: Swift.Error, Hashable {
        case emptyPassword
        case passwordTooShort
        case passwordTooLong
        case passwordMissingCapitalLetter
        case passwordMissingDigit
    }

    public static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }

    public init(id: UserID, password: String) throws {
        super.init(id: id)
        try changePassword(old: "", new: password)
    }

    func changePassword(old: String, new password: String) throws {
        // FIXME: password is encrypted
//        try assertArgument(!password.isEmpty, Error.emptyPassword)
//        try assertArgument(password.count >= 6, Error.passwordTooShort)
//        try assertArgument(password.count <= 100, Error.passwordTooLong)
//        try assertArgument(password.hasUppercaseLetter, Error.passwordMissingCapitalLetter)
//        try assertArgument(password.hasDecimalDigit, Error.passwordMissingDigit)
        self.password = password
    }

    public func attachSession(id: SessionID) {
        sessionID = id
    }

}
