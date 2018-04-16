//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public struct AuthenticationPolicy: Hashable, Assertable {

    public var sessionDuration: TimeInterval

    public enum Error: Swift.Error, Hashable {
        case durationIsNotPositive
    }

    public init(sessionDuration: TimeInterval) throws {
        self.sessionDuration = sessionDuration
        try assertTrue(sessionDuration > 0, Error.durationIsNotPositive)
    }

}
