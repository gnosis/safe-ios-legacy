//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import IdentityAccessDomainModel
import IdentityAccessImplementations

class DomainTestCase: XCTestCase {

    let mockUserDefaults = InMemoryKeyValueStore()
    let keychain = MockKeychain()
    let biometricService = MockBiometricService()
    let mockClockService = MockClockService()
    let encryptionService = MockEncryptionService()
    let userRepository: SingleUserRepository = InMemoryUserRepository()
    let identityService = IdentityService()
    let gatekeeperRepository: SingleGatekeeperRepository = InMemoryGatekeeperRepository()

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: mockUserDefaults, for: KeyValueStore.self)
        DomainRegistry.put(service: keychain, for: SecureStore.self)
        DomainRegistry.put(service: biometricService, for: BiometricAuthenticationService.self)
        DomainRegistry.put(service: encryptionService, for: EncryptionServiceProtocol.self)
        DomainRegistry.put(service: userRepository, for: SingleUserRepository.self)
        DomainRegistry.put(service: identityService, for: IdentityService.self)
        DomainRegistry.put(service: gatekeeperRepository, for: SingleGatekeeperRepository.self)
    }

}
