//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

struct Session {

    var isActive: Bool {
        guard let startTime = startTime else { return false }
        return clockService.currentTime.timeIntervalSince(startTime) < duration
    }
    let duration: TimeInterval
    private var startTime: Date?
    private var clockService: Clock { return DomainRegistry.clock }

    init(duration: TimeInterval) {
        self.duration = duration
    }

    mutating func start() {
        startTime = clockService.currentTime
    }

}
