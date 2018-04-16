//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

struct SessionID: Hashable, Assertable {

    let id: String

    enum Error: Swift.Error, Hashable {
        case invalidID
    }

    init(_ id: String) throws {
        self.id = id
        try assertTrue(id.count == 36, Error.invalidID)
    }

}

class XSession: Assertable {

    enum Error: Swift.Error, Hashable {
        case invalidDuration
        case sessionWasActiveAlready
        case sessionIsNotActive
        case sessionWasFinishedAlready
    }

    private let duration: TimeInterval
    private var startedAt: Date?
    private var endedAt: Date?
    private var updatedAt: Date?
    let sessionID: SessionID

    init(id: SessionID, durationInSeconds: TimeInterval) throws {
        sessionID = id
        duration = durationInSeconds
        try assertTrue(durationInSeconds > 0, Error.invalidDuration)
    }

    func isActiveAt(_ time: Date) -> Bool {
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

    func start(_ time: Date) throws {
        try assertNil(endedAt, Error.sessionWasFinishedAlready)
        try assertFalse(isActiveAt(time), Error.sessionWasActiveAlready)
        startedAt = time
    }

    func finish(_ time: Date) throws {
        try assertTrue(isActiveAt(time), Error.sessionIsNotActive)
        endedAt = time
    }

    func renew(_ time: Date) throws {
        try assertTrue(isActiveAt(time), Error.sessionIsNotActive)
        updatedAt = time
    }
}
