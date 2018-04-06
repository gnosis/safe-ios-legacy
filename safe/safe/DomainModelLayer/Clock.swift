//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

protocol Clock: class {
    var currentTime: Date { get }
    func countdown(from period: TimeInterval, tick: @escaping (TimeInterval) -> Void)
}
