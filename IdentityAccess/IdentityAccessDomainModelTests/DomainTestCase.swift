//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import IdentityAccessDomainModel
import IdentityAccessImplementations

/// Base test case class for domain model tests
class DomainTestCase: XCTestCase {

    let biometricService = MockBiometricService()
    let mockClockService = MockClockService()
    let encryptionService = MockEncryptionService()
    let userRepository: SingleUserRepository = InMemoryUserRepository()
    let identityService = IdentityService()
    let gatekeeperRepository: SingleGatekeeperRepository = InMemoryGatekeeperRepository()

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: biometricService, for: BiometricAuthenticationService.self)
        DomainRegistry.put(service: encryptionService, for: EncryptionService.self)
        DomainRegistry.put(service: userRepository, for: SingleUserRepository.self)
        DomainRegistry.put(service: identityService, for: IdentityService.self)
        DomainRegistry.put(service: gatekeeperRepository, for: SingleGatekeeperRepository.self)
    }

}
