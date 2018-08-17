//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public class Repeat {

    private let main: (Repeat) throws -> Void
    private let delay: TimeInterval
    private var stopped: Bool = false

    public init (delay: TimeInterval, _ main: @escaping (Repeat) throws -> Void) {
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
