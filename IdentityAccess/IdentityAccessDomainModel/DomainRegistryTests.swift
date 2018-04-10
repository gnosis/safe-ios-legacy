//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import IdentityAccessDomainModel
import IdentityAccessImplementations

class DomainRegistryTests: XCTestCase {

    func test_exists() {
        DomainRegistry.put(service: InMemoryKeyValueStore(), for: KeyValueStore.self)
        DomainRegistry.put(service: MockKeychain(), for: SecureStore.self)
        DomainRegistry.put(service: MockBiometricService(), for: BiometricAuthenticationService.self)
        DomainRegistry.put(service: MockClockService(), for: Clock.self)
        DomainRegistry.put(service: MockLogger(), for: Logger.self)
        DomainRegistry.put(service: MockEncryptionService(), for: EncryptionServiceProtocol.self)
        XCTAssertNotNil(DomainRegistry.keyValueStore)
        XCTAssertNotNil(DomainRegistry.secureStore)
        XCTAssertNotNil(DomainRegistry.biometricAuthenticationService)
        XCTAssertNotNil(DomainRegistry.clock)
        XCTAssertNotNil(DomainRegistry.logger)
        XCTAssertNotNil(DomainRegistry.encryptionService)
    }

}
