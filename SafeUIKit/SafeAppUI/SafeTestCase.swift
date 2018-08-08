//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import IdentityAccessApplication
import IdentityAccessDomainModel
import IdentityAccessImplementations
import MultisigWalletDomainModel
import MultisigWalletApplication
import MultisigWalletImplementations
import MultisigWalletApplication
import Common

class SafeTestCase: XCTestCase {

    let ethereumService = MockEthereumApplicationService()
    let walletService = MockWalletApplicationService()
    let authenticationService = MockAuthenticationService()
    let clock = MockClockService()
    let logger = MockLogger()

    override func setUp() {
        super.setUp()
        configureIdentityAccessModule()
        configureMultisigWalletModule()
        configureEthereumModule()
    }

    private func configureIdentityAccessModule() {
        let domainRegistry = IdentityAccessDomainModel.DomainRegistry.self
        domainRegistry.put(service: CommonCryptoEncryptionService(), for: EncryptionService.self)
        domainRegistry.put(service: MockBiometricService(), for: BiometricAuthenticationService.self)
        domainRegistry.put(service: InMemoryUserRepository(), for: SingleUserRepository.self)
        domainRegistry.put(service: InMemoryGatekeeperRepository(), for: SingleGatekeeperRepository.self)
        domainRegistry.put(service: IdentityService(), for: IdentityService.self)

        let applicationRegistry = IdentityAccessApplication.ApplicationServiceRegistry.self
        applicationRegistry.put(service: logger, for: Logger.self)
        applicationRegistry.put(service: authenticationService, for: AuthenticationApplicationService.self)
        applicationRegistry.put(service: clock, for: Clock.self)
    }

    private func configureMultisigWalletModule() {
        let applicationRegistry = MultisigWalletApplication.ApplicationServiceRegistry.self
        applicationRegistry.put(service: walletService, for: WalletApplicationService.self)
    }

    private func configureEthereumModule() {
        let applicationRegistry = MultisigWalletApplication.ApplicationServiceRegistry.self
        applicationRegistry.put(service: ethereumService, for: EthereumApplicationService.self)
    }

}
