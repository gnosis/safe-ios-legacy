//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import IdentityAccessDomainModel
import IdentityAccessImplementations

class DomainRegistryTests: XCTestCase {

    func test_exists() {
        DomainRegistry.put(service: InMemoryKeyValueStore(), for: KeyValueStore.self)
        DomainRegistry.put(service: MockKeychain(), for: SecureStore.self)
        DomainRegistry.put(service: MockBiometricService(), for: BiometricAuthenticationService.self)
        DomainRegistry.put(service: MockEncryptionService(), for: EncryptionServiceProtocol.self)
        DomainRegistry.put(service: InMemoryUserRepository(), for: UserRepository.self)
        DomainRegistry.put(service: IdentityService(), for: IdentityService.self)
        XCTAssertNotNil(DomainRegistry.keyValueStore)
        XCTAssertNotNil(DomainRegistry.secureStore)
        XCTAssertNotNil(DomainRegistry.biometricAuthenticationService)
        XCTAssertNotNil(DomainRegistry.encryptionService)
        XCTAssertNotNil(DomainRegistry.userRepository)
        XCTAssertNotNil(DomainRegistry.identityService)
    }

}
