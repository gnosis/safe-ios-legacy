//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

/// Repeats a closure until stopped explicitly, delaying every repetition with a configured `delay` time interval.
public class Repeater {

    private let main: (Repeater) throws -> Void
    private let delay: TimeInterval
    private var stopped: Bool = false

    public init (delay: TimeInterval, _ main: @escaping (Repeater) throws -> Void) {
        self.main = main
        self.delay = delay
    }

    public func start() throws {
        while true {
            try main(self)
            if stopped { return }
            Common.Timer.wait(delay)
        }
    }

    public func stop() {
        stopped = true
    }

}
