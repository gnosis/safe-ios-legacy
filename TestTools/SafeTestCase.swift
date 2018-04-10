//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe
import IdentityAccessApplication
import IdentityAccessDomainModel
import IdentityAccessImplementations
import IdentityAccessImplementationsTestSupport

class SafeTestCase: XCTestCase {

    let authenticationService = MockAuthenticationService()
    let clock = MockClockService()
    let identityService = IdentityApplicationService()

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: MockSecureStore(), for: SecureStore.self)
        DomainRegistry.put(service: EncryptionService(), for: EncryptionServiceProtocol.self)
        ApplicationServiceRegistry.put(service: authenticationService,
                                       for: AuthenticationApplicationService.self)
        ApplicationServiceRegistry.put(service: clock, for: Clock.self)
        ApplicationServiceRegistry.put(service: identityService, for: IdentityApplicationService.self)
    }

}
