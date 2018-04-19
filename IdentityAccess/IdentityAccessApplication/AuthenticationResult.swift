//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public enum AuthenticationStatus: Hashable {
    case success
    case failure
    case blocked
}

public struct AuthenticationResult {
    public let status: AuthenticationStatus
    public let userID: String!

    public static let blocked = AuthenticationResult(status: .blocked, userID: nil)
    public static let failure = AuthenticationResult(status: .failure, userID: nil)
    public static func success(userID: String) -> AuthenticationResult {
        return AuthenticationResult(status: .success, userID: userID)
    }
}
