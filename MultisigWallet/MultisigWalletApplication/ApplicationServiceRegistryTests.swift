//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import EthereumApplication
import EthereumDomainModel

class ApplicationServiceRegistryTests: EthereumApplicationTestCase {

    func test_services() {
        XCTAssertNotNil(ApplicationServiceRegistry.ethereumService)
    }

}
