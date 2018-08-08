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

    /// Serialized session state
    struct State: Codable {
        fileprivate let id: String
        fileprivate let duration: TimeInterval
        fileprivate let startedAt: Date?
        fileprivate let endedAt: Date?
        fileprivate let updatedAt: Date?
    }

    private let duration: TimeInterval
    private var startedAt: Date?
    private var endedAt: Date?
    private var updatedAt: Date?

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

    /// Creates new Session from a serialized Data value
    ///
    /// - Parameter data: serialized session
    /// - Throws: error fi failed to decode session
    public convenience init(data: Data) throws {
        let decoder = PropertyListDecoder()
        let state = try decoder.decode(State.self, from: data)
        try self.init(id: SessionID(state.id), durationInSeconds: state.duration)
        startedAt = state.startedAt
        endedAt = state.endedAt
        updatedAt = state.updatedAt
    }

    /// Serializes session's state into Data
    ///
    /// - Returns: serialized session
    /// - Throws: error if serialization failes
    public func data() throws -> Data {
        let state = State(id: id.id, duration: duration, startedAt: startedAt, endedAt: endedAt, updatedAt: updatedAt)
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        return try encoder.encode(state)
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
