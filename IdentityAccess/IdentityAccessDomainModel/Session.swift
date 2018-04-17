//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public class SessionID: BaseID {}

public class Session: IdentifiedEntity<SessionID> {

    public enum Error: Swift.Error, Hashable {
        case invalidDuration
        case sessionWasActiveAlready
        case sessionIsNotActive
        case sessionWasFinishedAlready
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
