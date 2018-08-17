//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public class Retry<T> {

    private let main: (Int) throws -> T
    private let maxAttempts: Int
    private let delay: TimeInterval

    public init(maxAttempts: Int, delay: TimeInterval = 0, _ main: @escaping (Int) throws -> T) {
        self.main = main
        self.maxAttempts = maxAttempts
        self.delay = delay
    }

    public func start() throws -> T {
        var attempt = 0
        var error: Error!
        while attempt < maxAttempts {
            if attempt > 0 {
                Common.Timer.wait(TimeInterval(attempt) * delay)
            }
            do {
                return try main(attempt)
            } catch let e {
                attempt += 1
                error = e
            }
        }
        throw error
    }

}
