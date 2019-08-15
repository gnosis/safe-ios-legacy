//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import IdentityAccessDomainModel
import IdentityAccessImplementations

class DomainRegistryTests: XCTestCase {

    func test_exists() {
        DomainRegistry.put(service: MockBiometricService(), for: BiometricAuthenticationService.self)
        DomainRegistry.put(service: MockEncryptionService(), for: EncryptionService.self)
        DomainRegistry.put(service: InMemoryUserRepository(), for: SingleUserRepository.self)
        DomainRegistry.put(service: IdentityService(), for: IdentityService.self)
        XCTAssertNotNil(DomainRegistry.biometricAuthenticationService)
        XCTAssertNotNil(DomainRegistry.encryptionService)
        XCTAssertNotNil(DomainRegistry.userRepository)
        XCTAssertNotNil(DomainRegistry.identityService)
    }

}
