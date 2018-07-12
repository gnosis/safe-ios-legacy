//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public class SessionID: BaseID {}

public class Session: IdentifiableEntity<SessionID> {

    public enum Error: Swift.Error, Hashable {
        case invalidDuration
        case sessionWasActiveAlready
        case sessionIsNotActive
        case sessionWasFinishedAlready
    }

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

    public init(id: SessionID, durationInSeconds: TimeInterval) throws {
        duration = durationInSeconds
        super.init(id: id)
        try assertTrue(durationInSeconds > 0, Error.invalidDuration)
    }

    public convenience init(data: Data) throws {
        let decoder = PropertyListDecoder()
        let state = try decoder.decode(State.self, from: data)
        try self.init(id: SessionID(state.id), durationInSeconds: state.duration)
        startedAt = state.startedAt
        endedAt = state.endedAt
        updatedAt = state.updatedAt
    }

    public func data() throws -> Data {
        let state = State(id: id.id, duration: duration, startedAt: startedAt, endedAt: endedAt, updatedAt: updatedAt)
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        return try encoder.encode(state)
    }

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

    public func start(_ time: Date) throws {
        try assertNil(endedAt, Error.sessionWasFinishedAlready)
        try assertFalse(isActiveAt(time), Error.sessionWasActiveAlready)
        startedAt = time
    }

    public func finish(_ time: Date) throws {
        try assertTrue(isActiveAt(time), Error.sessionIsNotActive)
        endedAt = time
    }

    public func renew(_ time: Date) throws {
        try assertTrue(isActiveAt(time), Error.sessionIsNotActive)
        updatedAt = time
    }
}
