//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

/// Represents authentication intent
public struct AuthenticationRequest {

    /// Method to authenticate with
    public let method: AuthenticationMethod
    /// If method is `password` authentication, then this has the password in plain text
    public let password: String!

    private init(with method: AuthenticationMethod, _ password: String? = nil) {
        precondition(method == .biometry && password == nil ||
            method == .password && password != nil, "Invalid authentication request")
        self.method = method
        self.password = password
    }

    /// Creates a biomtric authentication request, that is authentication with either Touch ID or Face ID
    ///
    /// - Returns: New biometric authentication request
    public static func biometry() -> AuthenticationRequest {
        return AuthenticationRequest(with: .biometry)
    }

    /// Creates a password authentication request with the password in plain text.
    ///
    /// - Parameter password: Plain-text password to authenticate with
    /// - Returns: New password authentication request
    public static func password(_ password: String) -> AuthenticationRequest {
        return AuthenticationRequest(with: .password, password)
    }

}
