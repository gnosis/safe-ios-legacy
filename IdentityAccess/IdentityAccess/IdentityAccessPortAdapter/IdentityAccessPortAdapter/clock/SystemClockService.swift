//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

final class SystemClockService: Clock {

    var currentTime: Date {
        return Date()
    }

    func countdown(from period: TimeInterval, tick: @escaping (TimeInterval) -> Void) {
        var timeLeft = period
        let step: TimeInterval = 1
        Timer.scheduledTimer(withTimeInterval: step, repeats: true) { timer in
            timeLeft -= step
            tick(timeLeft)
            if timeLeft == 0 {
                timer.invalidate()
            }
        }
        tick(timeLeft)
    }

}
