//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public struct SessionConfiguration: Hashable, Assertable {

    public var duration: TimeInterval

    public enum Error: Swift.Error, Hashable {
        case durationIsNotPositive
    }

    public init(duration: TimeInterval) throws {
        self.duration = duration
        try assertTrue(duration > 0, Error.durationIsNotPositive)
    }

}
