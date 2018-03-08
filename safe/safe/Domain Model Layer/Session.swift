//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

struct Session {

    var isActive: Bool {
        return false
    }
    let duration: TimeInterval
    private var startTime: Date?

    init(duration: TimeInterval) {
        self.duration = duration
    }

    mutating func start() {

    }

}
