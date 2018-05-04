//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import IdentityAccessApplication
import IdentityAccessDomainModel
import IdentityAccessImplementations

class SafeTestCase: XCTestCase {

    let authenticationService = MockAuthenticationService()
    let clock = MockClockService()
    let identityService = MockIdentityApplicationService()
    let keyValueStore = InMemoryKeyValueStore()
    let secureStore = InMemorySecureStore()
    let logger = MockLogger()

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: secureStore, for: SecureStore.self)
        DomainRegistry.put(service: keyValueStore, for: KeyValueStore.self)
        DomainRegistry.put(service: EncryptionService(), for: EncryptionServiceProtocol.self)
        DomainRegistry.put(service: MockBiometricService(), for: BiometricAuthenticationService.self)
        DomainRegistry.put(service: InMemoryUserRepository(), for: SingleUserRepository.self)
        DomainRegistry.put(service: InMemoryGatekeeperRepository(), for: SingleGatekeeperRepository.self)
        DomainRegistry.put(service: IdentityService(), for: IdentityService.self)

        ApplicationServiceRegistry.put(service: logger, for: Logger.self)
        ApplicationServiceRegistry.put(service: authenticationService, for: AuthenticationApplicationService.self)
        ApplicationServiceRegistry.put(service: clock, for: Clock.self)
        ApplicationServiceRegistry.put(service: identityService, for: IdentityApplicationService.self)
    }

}
