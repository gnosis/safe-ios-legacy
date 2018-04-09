//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class SafeTestCase: XCTestCase {

    let authenticationService = MockAuthenticationService()
    let clock = MockClockService()
    let identityService = MockIdentityService()

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: authenticationService,
                                       for: AuthenticationApplicationService.self)
        ApplicationServiceRegistry.put(service: clock, for: Clock.self)
        ApplicationServiceRegistry.put(service: identityService, for: IdentityApplicationService.self)
    }

}
