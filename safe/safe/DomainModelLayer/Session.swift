//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

struct Session {

    var isActive: Bool {
        guard let startTime = startTime else { return false }
        return clockService.currentTime.timeIntervalSince(startTime) < duration
    }
    let duration: TimeInterval
    private var startTime: Date?
    private let clockService: Clock

    init(duration: TimeInterval, clockService: Clock = SystemClockService()) {
        self.duration = duration
        self.clockService = clockService
    }

    mutating func start() {
        startTime = clockService.currentTime
    }

}
