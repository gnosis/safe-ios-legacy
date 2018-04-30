//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public struct AuthenticationPolicy: Hashable, Assertable, Codable {

    public enum Error: Swift.Error, Hashable {
        case sessionDurationMustBePositive
        case maxFailedAttemptsMustBePositive
        case blockDurationMustBeNonNegative
    }
    public let sessionDuration: TimeInterval
    public let maxFailedAttempts: Int
    public let blockDuration: TimeInterval

    public init(sessionDuration: TimeInterval, maxFailedAttempts: Int, blockDuration: TimeInterval) throws {
        self.sessionDuration = sessionDuration
        self.maxFailedAttempts = maxFailedAttempts
        self.blockDuration = blockDuration
        try assertTrue(sessionDuration > 0, Error.sessionDurationMustBePositive)
        try assertTrue(maxFailedAttempts > 0, Error.maxFailedAttemptsMustBePositive)
        try assertTrue(blockDuration >= 0, Error.blockDurationMustBeNonNegative)
    }

    func withSessionDuration(_ newValue: TimeInterval) throws -> AuthenticationPolicy {
        return try AuthenticationPolicy(sessionDuration: newValue,
                                        maxFailedAttempts: maxFailedAttempts,
                                        blockDuration: blockDuration)
    }

    func withMaxFailedAttempts(_ newValue: Int) throws -> AuthenticationPolicy {
        return try AuthenticationPolicy(sessionDuration: sessionDuration,
                                        maxFailedAttempts: newValue,
                                        blockDuration: blockDuration)
    }

    func withBlockDuration(_ newValue: TimeInterval) throws -> AuthenticationPolicy {
        return try AuthenticationPolicy(sessionDuration: sessionDuration,
                                        maxFailedAttempts: maxFailedAttempts,
                                        blockDuration: newValue)
    }

}
