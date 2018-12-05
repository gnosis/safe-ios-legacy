//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

/// ID of a gatekeeper entity
public class GatekeeperID: BaseID {}

/// Controls access with a blocking behavior. Based on parameters from `AuthenticationPolicy`, gatekeeper
/// keeps track of failed and successful access attempts, using methods `Gatekeeper.allowAccess(at:)` and
/// `Gatekeeper.denyAccess(at:)`. When failed access attempts reaches maximum, the access is blocked for
/// a period of time, during which all access tries will fail. On every use of existing access, please call
/// `Gatekeeper.useAccess(at:)` method.
///
/// `Gatekeeper` is an Aggregate Root entity for `AuthenticationPolicy` value object and for `Session` entity.
public class Gatekeeper: IdentifiableEntity<GatekeeperID> {

    /// Errors thrown from Gatekeeper's methods
    ///
    /// - durationIsNotPositive: duration must be positive
    /// - accessBlocked: authentication is blocked because number of failing attempts reached maximum.
    public enum Error: Swift.Error, Hashable {
        case durationIsNotPositive
        case accessBlocked
    }

    public convenience init(id: GatekeeperID,
                            session: Session?,
                            policy: AuthenticationPolicy,
                            failedAttemptCount: Int,
                            accessDeniedAt: Date?) {
        self.init(id: id, policy: policy)
        self.session = session
        self.failedAttemptCount = failedAttemptCount
        self.accessDeniedAt = accessDeniedAt
    }

    /// Policy configures parameters of gatekeeper's behavior. On every change of policy, gatekeeper's state is reset.
    public private(set) var policy: AuthenticationPolicy {
        didSet {
            reset()
        }
    }
    public private(set) var session: Session?
    public private(set) var failedAttemptCount: Int = 0
    public private(set) var accessDeniedAt: Date?

    /// Creates new gatekeeper with id and authentication policy
    ///
    /// - Parameters:
    ///   - id: gatekeeper's id
    ///   - policy: authentication policy
    public init(id: GatekeeperID, policy: AuthenticationPolicy) {
        self.policy = policy
        super.init(id: id)
    }

    /// Changes policy's session duration
    ///
    /// - Parameter newValue: new duration
    /// - Throws: error if new value is invalid
    public func changeSessionDuration(_ newValue: TimeInterval) throws {
        policy = try policy.withSessionDuration(newValue)
    }

    /// Changes policy's max failed attempts
    ///
    /// - Parameter newValue: new value
    /// - Throws: error if new value is invalid
    public func changeMaxFailedAttempts(_ newValue: Int) throws {
        policy = try policy.withMaxFailedAttempts(newValue)
    }

    /// Changes policy's block duration
    ///
    /// - Parameter newValue: new duration
    /// - Throws: error if new value is invalid
    public func changeBlockDuration(_ newValue: TimeInterval) throws {
        policy = try policy.withBlockDuration(newValue)
    }

    /// Checks whether it is possible to authenticate at the `time` moment.
    /// Access may be denied if maxFailedAttempts was reached before or blocking period is not lifted yet.
    ///
    /// - Parameter time: current time of access check
    /// - Returns: true if access possible, false otherwise
    public func isAccessPossible(at time: Date) -> Bool {
        guard let deniedTime = accessDeniedAt else { return true }
        let blockLiftTime = deniedTime.addingTimeInterval(policy.blockDuration)
        let isBlockPeriodExpired = time >= blockLiftTime
        let hasMoreAttempts = failedAttemptCount < policy.maxFailedAttempts
        return hasMoreAttempts || isBlockPeriodExpired
    }

    /// Allows access at the `time` moment, if access not blocked (otherwise throws error).
    /// This starts new session and resets failed attempts counter.
    /// This method is intended to be called when authentication was successful.
    ///
    /// - Parameter time: current moment to allow access.
    /// - Returns: new session id
    /// - Throws: error if blocking period is not lifted yet.
    public func allowAccess(at time: Date) throws -> SessionID {
        try assertNotBlocked(at: time)
        let session = try Session(id: SessionID(UUID().uuidString), durationInSeconds: policy.sessionDuration)
        try session.start(time)
        self.session = session
        failedAttemptCount = 0
        accessDeniedAt = nil
        return session.id
    }

    private func assertNotBlocked(at time: Date) throws {
        try assertTrue(isAccessPossible(at: time), Error.accessBlocked)
    }

    /// Tells Gatekeeper that authentication failed and should be counted towards blocking
    ///
    /// - Parameter time: current time of access
    public func denyAccess(at time: Date) {
        session = nil
        failedAttemptCount += 1
        accessDeniedAt = time
    }

    /// Check whether session is still active at the `time`.
    ///
    /// - Parameters:
    ///   - id: session id
    ///   - time: current time
    /// - Returns: true if session is active, false otherwise
    public func hasAccess(session id: SessionID, at time: Date) -> Bool {
        guard let session = session, session.id == id else { return false }
        return session.isActiveAt(time)
    }

    /// Notifies Gatekeeper that system was used. This allows to renew current session.
    ///
    /// - Parameter time: current time
    /// - Throws: error if session is not active anymore
    public func useAccess(at time: Date) throws {
        try assertNotBlocked(at: time)
        try session?.renew(time)
    }

    /// Resets session and failed access attempts counter.
    public func reset() {
        session = nil
        failedAttemptCount = 0
        accessDeniedAt = nil
    }

}
