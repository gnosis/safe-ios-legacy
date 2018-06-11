//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

/// Valid authentication methods supported by the application
public struct AuthenticationMethod: OptionSet {

    public let rawValue: Int

    public static let password = AuthenticationMethod(rawValue: 1 << 0)
    public static let touchID = AuthenticationMethod(rawValue: 1 << 1)
    public static let faceID = AuthenticationMethod(rawValue: 1 << 2)

    public static let biometry: AuthenticationMethod = [.touchID, .faceID]

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
