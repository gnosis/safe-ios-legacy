//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

/// Repeats a closure until stopped explicitly, delaying every repetition with a configured `delay` time interval.
public class Repeater {

    private enum State {
        case stopped
        case running
        case waiting
    }

    private let main: (Repeater) throws -> Void
    private let delay: TimeInterval
    private var state: State = .stopped
    public var isStopped: Bool { return state == .stopped }
    public var isRunning: Bool { return state == .running }

    public init (delay: TimeInterval, _ main: @escaping (Repeater) throws -> Void) {
        self.main = main
        self.delay = delay
    }

    public func start() throws {
        guard isStopped else { return }
        repeat {
            state = .running
            try main(self)
            if isStopped { return }
            state = .waiting
            Common.Timer.wait(delay)
        } while !isStopped
    }

    public func stop() {
        state = .stopped
    }

}
