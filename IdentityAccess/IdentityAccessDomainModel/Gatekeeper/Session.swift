//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public class SessionID: BaseID {}

/// Represents period of time when authentication is still valid and is still in use.
/// Session can be started, renewed and finished. At any moment, session's state can be
/// queried with `Session.isActive(at:)` method.
public class Session: IdentifiableEntity<SessionID> {

    /// Errors thrown from session's methods
    ///
    /// - invalidDuration: session duration value is invalid
    /// - sessionWasActiveAlready: session must not be active, but was active.
    /// - sessionIsNotActive: session must be active, but was inactive
    /// - sessionWasFinishedAlready: session has finished already, but shouldn't be.
    public enum Error: Swift.Error, Hashable {
        case invalidDuration
        case sessionWasActiveAlready
        case sessionIsNotActive
        case sessionWasFinishedAlready
    }

    public let duration: TimeInterval
    public private(set) var startedAt: Date?
    public private(set) var endedAt: Date?
    public private(set) var updatedAt: Date?

    /// Creates new session with id and duration.
    ///
    /// - Parameters:
    ///   - id: id of the session
    ///   - durationInSeconds: session duration
    /// - Throws: error if duration is not positive
    public init(id: SessionID, durationInSeconds: TimeInterval) throws {
        duration = durationInSeconds
        super.init(id: id)
        try assertTrue(durationInSeconds > 0, Error.invalidDuration)
    }

    public convenience init(id: SessionID,
                            duration: TimeInterval,
                            startedAt: Date?,
                            endedAt: Date?,
                            updatedAt: Date?) throws {
        try self.init(id: id, durationInSeconds: duration)
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.updatedAt = updatedAt
    }

    /// Checks whether session is active at the `time`.
    ///
    /// - Parameter time: current time
    /// - Returns: true if session active, false otherwise.
    public func isActiveAt(_ time: Date) -> Bool {
        guard endedAt == nil else { return false }
        guard let startTime = startedAt else { return false }
        let endTime: Date
        if let updateTime = updatedAt {
            endTime = updateTime.addingTimeInterval(duration)
        } else {
            endTime = startTime.addingTimeInterval(duration)
        }
        let activeTimePeriod = (startTime ... endTime)
        return activeTimePeriod.contains(time)
    }

    /// Starts new session. Session must be fresh, i.e. not finished or started before and not expired.
    ///
    /// - Parameter time: current time
    /// - Throws: error if session was finished or active.
    public func start(_ time: Date) throws {
        try assertNil(endedAt, Error.sessionWasFinishedAlready)
        try assertFalse(isActiveAt(time), Error.sessionWasActiveAlready)
        startedAt = time
    }

    /// Finishes currently active session. Session must be started already.
    ///
    /// - Parameter time: current time
    /// - Throws: error if session is not active
    public func finish(_ time: Date) throws {
        try assertTrue(isActiveAt(time), Error.sessionIsNotActive)
        endedAt = time
    }

    /// Renews current session. Session must be started before.
    ///
    /// - Parameter time: current time
    /// - Throws: error if session is not active.
    public func renew(_ time: Date) throws {
        try assertTrue(isActiveAt(time), Error.sessionIsNotActive)
        updatedAt = time
    }
}
