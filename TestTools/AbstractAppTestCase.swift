//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class AbstractAppTestCase: XCTestCase {

    var account = MockAccount()
    let authenticationService = MockAuthenticationService()
    let clock = MockClockService()

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: AuthenticationApplicationService(account: account),
                                       for: AuthenticationApplicationService.self)
        ApplicationServiceRegistry.put(service: clock, for: Clock.self)
    }

}
