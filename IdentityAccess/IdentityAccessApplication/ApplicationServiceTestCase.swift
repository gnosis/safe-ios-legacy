//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import IdentityAccessApplication
import IdentityAccessDomainModel
import IdentityAccessImplementations

class ApplicationServiceTestCase: XCTestCase {

    let identityService = IdentityApplicationService()

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: AuthenticationApplicationService(),
                                       for: AuthenticationApplicationService.self)
        ApplicationServiceRegistry.put(service: identityService, for: IdentityApplicationService.self)
        ApplicationServiceRegistry.put(service: MockClockService(), for: Clock.self)
    }
}
