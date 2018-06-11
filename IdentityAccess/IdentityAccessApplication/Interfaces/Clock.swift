//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

/// The Clock protocol allows to test and decouple time-based algorithms.
public protocol Clock: class {

    /// Returns current time
    var currentTime: Date { get }

    /// Calls `tick` every second for `period` seconds.
    ///
    /// - Parameters:
    ///   - period: Time to countdown from.
    ///   - tick: closure to execute on every second.
    ///   - timeLeft: how much time left until t = 0
    func countdown(from period: TimeInterval, tick: @escaping (_ timeLeft: TimeInterval) -> Void)

}
