//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import EthereumApplication

class ApplicationServiceRegistryTests: XCTestCase {

    func test_ethereumService() {
        let mock = MockEthereumApplicationService()
        ApplicationServiceRegistry.put(service: mock, for: EthereumApplicationService.self)
        XCTAssertTrue(ApplicationServiceRegistry.ethereumService === mock)
    }

}
