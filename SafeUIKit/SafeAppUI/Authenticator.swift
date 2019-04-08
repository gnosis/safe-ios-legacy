//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import IdentityAccessApplication

class Authenticator {

    var user: String?

    static let instance = Authenticator()

    private init() {}

    func authenticate(_ request: AuthenticationRequest) throws -> AuthenticationResult {
        let result = try ApplicationServiceRegistry.authenticationService.authenticateUser(request)
        if case AuthenticationResult.success(userID: let userID) = result {
            user = userID
        }
        return result
    }

    func registerUser(password: String) throws {
        try ApplicationServiceRegistry.authenticationService.registerUser(password: password)
        _ = try authenticate(.password(password))
    }

    func updateUserPassword(with password: String) throws {
        try ApplicationServiceRegistry.authenticationService.updatePrimaryUserPassword(with: password)
        _ = try authenticate(.password(password))
    }

}
