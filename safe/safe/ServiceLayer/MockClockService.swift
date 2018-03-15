//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation
@testable import safe

class MockClockService: SystemClockServiceProtocol {

    var currentTime = Date()

    var countdownTickBlock: ((TimeInterval) -> Void)?

    func countdown(from period: TimeInterval, tick: @escaping (TimeInterval) -> Void) {
        countdownTickBlock = tick
    }

}
