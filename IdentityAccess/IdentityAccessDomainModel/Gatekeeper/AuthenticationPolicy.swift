//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

/// Configures `Gatekeeper`'s behavior for session duration, failed auth attempt count, and block period duration.
public struct AuthenticationPolicy: Hashable, Assertable, Codable {

    /// Error thrown on invalid values of the policy.
    ///
    /// - sessionDurationMustBePositive: session duration is negative or zero
    /// - maxFailedAttemptsMustBePositive: maxFailedAttempts is negative or zero
    /// - blockDurationMustBeNonNegative: blockDuration is negative
    public enum Error: Swift.Error, Hashable {
        case sessionDurationMustBePositive
        case maxFailedAttemptsMustBePositive
        case blockDurationMustBeNonNegative
    }
    /// Time period during which no authentication is requested.
    public let sessionDuration: TimeInterval
    /// Maximum number of failed authentication attempts before authentication becomes blocked for `blockDuration`.
    public let maxFailedAttempts: Int
    /// Block period during which authentication is forbidden.
    public let blockDuration: TimeInterval

    /// Creates new policy with specified values.
    ///
    /// - Parameters:
    ///   - sessionDuration: session duration
    ///   - maxFailedAttempts: max number of failing authentication attempts
    ///   - blockDuration: authentication blocking period duration
    /// - Throws: `AuthenticationPolicy.Error` in case provided values are invalid
    public init(sessionDuration: TimeInterval, maxFailedAttempts: Int, blockDuration: TimeInterval) throws {
        self.sessionDuration = sessionDuration
        self.maxFailedAttempts = maxFailedAttempts
        self.blockDuration = blockDuration
        try assertTrue(sessionDuration > 0, Error.sessionDurationMustBePositive)
        try assertTrue(maxFailedAttempts > 0, Error.maxFailedAttemptsMustBePositive)
        try assertTrue(blockDuration >= 0, Error.blockDurationMustBeNonNegative)
    }

    /// Creates new policy with different session duration
    ///
    /// - Parameter newValue: new value for session duration
    /// - Returns: new policy with changed value
    /// - Throws: error if new value is invalid
    func withSessionDuration(_ newValue: TimeInterval) throws -> AuthenticationPolicy {
        return try AuthenticationPolicy(sessionDuration: newValue,
                                        maxFailedAttempts: maxFailedAttempts,
                                        blockDuration: blockDuration)
    }

    /// Creates new policy with different maxFailedAttempts
    ///
    /// - Parameter newValue: new value for maxFailedAttempts
    /// - Returns: new policy with changed value
    /// - Throws: error if new value is invalid
    func withMaxFailedAttempts(_ newValue: Int) throws -> AuthenticationPolicy {
        return try AuthenticationPolicy(sessionDuration: sessionDuration,
                                        maxFailedAttempts: newValue,
                                        blockDuration: blockDuration)
    }

    /// Creates new policy with different block duration
    ///
    /// - Parameter newValue: new value for block duration
    /// - Returns: new policy with changed value
    /// - Throws: error if new value is invalid
    func withBlockDuration(_ newValue: TimeInterval) throws -> AuthenticationPolicy {
        return try AuthenticationPolicy(sessionDuration: sessionDuration,
                                        maxFailedAttempts: maxFailedAttempts,
                                        blockDuration: newValue)
    }

}
