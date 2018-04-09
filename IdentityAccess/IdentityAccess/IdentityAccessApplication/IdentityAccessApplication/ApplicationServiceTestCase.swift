//
//  Copyright © 2018 Dmitry Bespalov. All rights reserved.
//

import XCTest
@testable import IdentityAccessApplication
import IdentityAccessDomainModel
import IdentityAccessPortAdapterTestSupport

class ApplicationServiceTestCase: XCTestCase {

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: AuthenticationApplicationService(),
                                       for: AuthenticationApplicationService.self)
        ApplicationServiceRegistry.put(service: MockClockService(), for: Clock.self)
    }
}
