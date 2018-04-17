//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public protocol Clock: class {
    var currentTime: Date { get }
    func countdown(from period: TimeInterval, tick: @escaping (TimeInterval) -> Void)
}
