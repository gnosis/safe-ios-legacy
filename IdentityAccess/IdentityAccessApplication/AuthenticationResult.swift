//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

/// Result of the authentication
///
/// - success: authentication is successful
/// - failure: authentication failed
/// - blocked: authentication will be blocked
public enum AuthenticationResult: Hashable {
    case success(userID: String)
    case failure
    case blocked

    /// True if the authentication is successful
    public var isSuccess: Bool {
        if case AuthenticationResult.success = self { return true }
        return false
    }
}
