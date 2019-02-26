//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

/// Retries a closure while it keeps throwing errors until either maxAttempts reached, or closure won't throw.
/// Every retry is delayed by linearly increasing time interval, calculated as (attemptNumber * startDelay).
/// When maximum attempts count is reached, while closure is still throwing, last thrown error is rethrown.
final public class RetryWithIncreasingDelay<T> {

    private let main: (Int) throws -> T
    private let maxAttempts: Int
    private let delay: TimeInterval

    public init(maxAttempts: Int, startDelay: TimeInterval = 0, _ main: @escaping (Int) throws -> T) {
        self.main = main
        self.maxAttempts = maxAttempts
        self.delay = startDelay
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
