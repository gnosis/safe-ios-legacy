//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public struct AuthenticationRequest {

    public let method: AuthenticationMethod
    public let password: String!

    private init(_ method: AuthenticationMethod, _ password: String? = nil) {
        precondition(method == .biometry && password == nil ||
            method == .password && password != nil, "Invalid authentication request")
        self.method = method
        self.password = password
    }

    public static func biometry() -> AuthenticationRequest {
        return AuthenticationRequest(.biometry)
    }

    public static func password(_ password: String) -> AuthenticationRequest {
        return AuthenticationRequest(.password, password)
    }

}
