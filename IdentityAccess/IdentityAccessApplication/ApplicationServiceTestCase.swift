//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import IdentityAccessApplication
import IdentityAccessDomainModel
import IdentityAccessImplementations

class ApplicationServiceTestCase: XCTestCase {

    let authenticationService = AuthenticationApplicationService()
    let identityService = IdentityApplicationService()

    let userRepository = InMemoryUserRepository()

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: authenticationService,
                                       for: AuthenticationApplicationService.self)
        ApplicationServiceRegistry.put(service: identityService, for: IdentityApplicationService.self)
        ApplicationServiceRegistry.put(service: MockClockService(), for: Clock.self)

        DomainRegistry.put(service: userRepository, for: UserRepository.self)
    }
}
