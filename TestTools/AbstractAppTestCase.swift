//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe
import IdentityAccessApplication
import IdentityAccessDomainModel
import IdentityAccessPortAdapterTestSupport

class AbstractAppTestCase: XCTestCase {

    let authenticationService = MockAuthenticationService()
    let clock = MockClockService()

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: authenticationService,
                                       for: AuthenticationApplicationService.self)
        ApplicationServiceRegistry.put(service: clock, for: Clock.self)
    }

}
