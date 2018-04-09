//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import IdentityAccessDomainModel
import IdentityAccessPortAdapterTestSupport

class DomainTestCase: XCTestCase {

    let mockUserDefaults = InMemoryKeyValueStore()
    let keychain = MockKeychain()
    let biometricService = MockBiometricService()
    let mockClockService = MockClockService()
    let logger = MockLogger()

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: mockUserDefaults, for: KeyValueStore.self)
        DomainRegistry.put(service: keychain, for: SecureStore.self)
        DomainRegistry.put(service: biometricService, for: BiometricAuthenticationService.self)
        DomainRegistry.put(service: mockClockService, for: Clock.self)
        DomainRegistry.put(service: logger, for: Logger.self)
    }

}
