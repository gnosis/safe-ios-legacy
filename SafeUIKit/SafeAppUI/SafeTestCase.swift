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
    let recoveryService = MockRecoveryApplicationService()
    let authenticationService = MockAuthenticationService()
    let clock = MockClockService()
    let logger = MockLogger()
    let eventPublisher = MockEventPublisher()
    var walletConnectService: MockWalletConnectApplicationService!
    let walletConnectSessionRepository = InMemoryWCSessionRepository()
    let appSettingsRepository = UserDefaultsAppSettingsRepository()

    let applicationRegistry = MultisigWalletApplication.ApplicationServiceRegistry.self

    override func setUp() {
        super.setUp()
        configureMultisigWalletModule()
        configureIdentityAccessModule()
        configureEthereumModule()
        configureWalletConnectModule()
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

        MultisigWalletDomainModel.DomainRegistry.put(service: eventPublisher, for: EventPublisher.self)
        MultisigWalletDomainModel.DomainRegistry.put(service: EventRelay(publisher: eventPublisher),
                                                     for: EventRelay.self)
        MultisigWalletDomainModel.DomainRegistry.put(service: ErrorStream(), for: ErrorStream.self)
    }

    private func configureMultisigWalletModule() {
        applicationRegistry.put(service: walletService, for: WalletApplicationService.self)
        MultisigWalletDomainModel.DomainRegistry.put(service: appSettingsRepository, for: AppSettingsRepository.self)
        applicationRegistry.put(service: recoveryService, for: RecoveryApplicationService.self)
    }

    private func configureEthereumModule() {
        applicationRegistry.put(service: ethereumService, for: EthereumApplicationService.self)
    }

    private func configureWalletConnectModule() {
        MultisigWalletDomainModel.DomainRegistry.put(service: WalletConnectService(),
                                                     for: WalletConnectDomainService.self)
        walletConnectService = MockWalletConnectApplicationService(chainId: 1)
        applicationRegistry.put(service: walletConnectService, for: WalletConnectApplicationService.self)
        MultisigWalletDomainModel.DomainRegistry.put(service: walletConnectSessionRepository,
                                                     for: WalletConnectSessionRepository.self)

    }

    internal func reconfigureService(with config: WalletApplicationServiceConfiguration) {
        let walletService = MockWalletApplicationService(configuration: config)
        ApplicationServiceRegistry.put(service: walletService, for: WalletApplicationService.self)
    }

}
