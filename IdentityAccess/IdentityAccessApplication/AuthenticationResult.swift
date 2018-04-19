//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public enum AuthenticationResult: Hashable {
    case success(userID: String)
    case failure
    case blocked

    public var isSuccess: Bool {
        if case AuthenticationResult.success = self { return true }
        return false
    }
}
