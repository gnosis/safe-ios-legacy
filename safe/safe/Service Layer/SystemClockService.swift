//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import Foundation

protocol SystemClockServiceProtocol: class {
    var currentTime: Date { get }
}

final class SystemClockService: SystemClockServiceProtocol {

    var currentTime: Date {
        return Date()
    }

}

