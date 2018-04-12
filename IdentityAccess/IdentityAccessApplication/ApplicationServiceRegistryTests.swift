//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import IdentityAccessApplication

class ApplicationServiceRegistryTests: ApplicationServiceTestCase {

    func test_authenticationService_exists() {
        XCTAssertNotNil(ApplicationServiceRegistry.authenticationService)
        XCTAssertNotNil(ApplicationServiceRegistry.clock)
        XCTAssertNotNil(ApplicationServiceRegistry.identityService)
    }

}
