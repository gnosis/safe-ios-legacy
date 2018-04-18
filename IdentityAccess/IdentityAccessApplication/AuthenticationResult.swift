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
    public let sessionID: String!

    public static let blocked = AuthenticationResult(status: .blocked, userID: nil, sessionID: nil)
    public static let failure = AuthenticationResult(status: .failure, userID: nil, sessionID: nil)
    public static func success(userID: String, sessionID: String) -> AuthenticationResult {
        return AuthenticationResult(status: .success, userID: userID, sessionID: sessionID)
    }
}
