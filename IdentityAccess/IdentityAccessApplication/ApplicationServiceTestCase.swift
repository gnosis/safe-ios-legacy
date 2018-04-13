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
    let userRepository: UserRepository = InMemoryUserRepository()
    let biometricService = MockBiometricService()
    let encryptionService = MockEncryptionService()

    override func setUp() {
        super.setUp()
        configureIdentityServiceDependencies()
        configureAuthenticationServiceDependencies()
        configureAccountDependencies()
    }

    private func configureIdentityServiceDependencies() {
        ApplicationServiceRegistry.put(service: identityService, for: IdentityApplicationService.self)
        ApplicationServiceRegistry.put(service: MockClockService(), for: Clock.self)
    }

    private func configureAuthenticationServiceDependencies() {
        ApplicationServiceRegistry.put(service: authenticationService,
                                       for: AuthenticationApplicationService.self)
        DomainRegistry.put(service: userRepository, for: UserRepository.self)
        DomainRegistry.put(service: biometricService, for: BiometricAuthenticationService.self)
        DomainRegistry.put(service: encryptionService, for: EncryptionServiceProtocol.self)
        DomainRegistry.put(service: IdentityService(), for: IdentityService.self)
    }

    private func configureAccountDependencies() {
        DomainRegistry.put(service: MockKeychain(), for: SecureStore.self)
        DomainRegistry.put(service: MockClockService(), for: Clock.self)
        DomainRegistry.put(service: InMemoryKeyValueStore(), for: KeyValueStore.self)
    }
}
