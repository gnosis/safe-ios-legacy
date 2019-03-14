//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

/// Repeats a closure until stopped explicitly, delaying every repetition with a configured `delay` time interval.
public class Repeater {

    private let main: (Repeater) throws -> Void
    private let delay: TimeInterval
    public private(set) var stopped: Bool = true
    public private(set) var waiting: Bool = false

    public init (delay: TimeInterval, _ main: @escaping (Repeater) throws -> Void) {
        self.main = main
        self.delay = delay
    }

    public func start() throws {
        guard stopped else { return }
        stopped = false
        waiting = false
        while !stopped {
            try main(self)
            if stopped { return }
            waiting = true
            Common.Timer.wait(delay)
            waiting = false
        }
    }

    public func stop() {
        stopped = true
        waiting = false
    }

}
