//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation
import IdentityAccessDomainModel

class MockClockService: Clock {

    var currentTime = Date()

    var countdownTickBlock: ((TimeInterval) -> Void)?

    func countdown(from period: TimeInterval, tick: @escaping (TimeInterval) -> Void) {
        countdownTickBlock = tick
    }

}
