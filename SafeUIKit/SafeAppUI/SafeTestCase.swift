//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import IdentityAccessApplication
import IdentityAccessDomainModel
import IdentityAccessImplementations
import MultisigWalletApplication

class SafeTestCase: XCTestCase {

    let walletService = MockWalletApplicationService()
    let authenticationService = MockAuthenticationService()
    let clock = MockClockService()
    let identityService = MockIdentityApplicationService()
    let keyValueStore = InMemoryKeyValueStore()
    let secureStore = InMemorySecureStore()
    let logger = MockLogger()

    override func setUp() {
        super.setUp()
        configureIdentityAccessModule()
        configureMultisigWalletModule()
    }

    private func configureIdentityAccessModule() {
        let domainRegistry = IdentityAccessDomainModel.DomainRegistry.self
        domainRegistry.put(service: secureStore, for: SecureStore.self)
        domainRegistry.put(service: keyValueStore, for: KeyValueStore.self)
        domainRegistry.put(service: EncryptionService(), for: EncryptionServiceProtocol.self)
        domainRegistry.put(service: MockBiometricService(), for: BiometricAuthenticationService.self)
        domainRegistry.put(service: InMemoryUserRepository(), for: SingleUserRepository.self)
        domainRegistry.put(service: InMemoryGatekeeperRepository(), for: SingleGatekeeperRepository.self)
        domainRegistry.put(service: IdentityService(), for: IdentityService.self)

        let applicationRegistry = IdentityAccessApplication.ApplicationServiceRegistry.self
        applicationRegistry.put(service: logger, for: Logger.self)
        applicationRegistry.put(service: authenticationService, for: AuthenticationApplicationService.self)
        applicationRegistry.put(service: clock, for: Clock.self)
        applicationRegistry.put(service: identityService, for: IdentityApplicationService.self)
    }

    private func configureMultisigWalletModule() {
        let applicationRegistry = MultisigWalletApplication.ApplicationServiceRegistry.self
        applicationRegistry.put(service: walletService, for: WalletApplicationService.self)
    }

}
