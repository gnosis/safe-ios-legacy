//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import IdentityAccessImplementations
import IdentityAccessDomainModel

class ConsoleLoggerTests: XCTestCase {

    let logger = ConsoleLogger()

    func test_canLog() {
        logger.log("Test Log", level: .info)
    }

}
