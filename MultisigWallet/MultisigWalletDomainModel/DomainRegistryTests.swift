//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel
import MultisigWalletImplementations

class DomainRegistryTests: XCTestCase {

    func test_whenServicesAreSet_thenTheyAreAvailable() {
        DomainRegistry.put(service: InMemoryWalletRepository(), for: WalletRepository.self)
        DomainRegistry.put(service: InMemorySinglePortfolioRepository(), for: SinglePortfolioRepository.self)
        DomainRegistry.put(service: MockNotificationService(), for: NotificationDomainService.self)
        DomainRegistry.put(service: MockPushTokensDomainService(), for: PushTokensDomainService.self)
        XCTAssertNotNil(DomainRegistry.walletRepository)
        XCTAssertNotNil(DomainRegistry.portfolioRepository)
        XCTAssertNotNil(DomainRegistry.notificationService)
        XCTAssertNotNil(DomainRegistry.pushTokensService)

        DomainRegistry.put(service: EncryptionService(), for: EncryptionDomainService.self)
        DomainRegistry.put(service: InMemoryExternallyOwnedAccountRepository(),
                           for: ExternallyOwnedAccountRepository.self)
        DomainRegistry.put(service: MockTransactionRelayService(averageDelay: 0, maxDeviation: 0),
                           for: TransactionRelayDomainService.self)
        DomainRegistry.put(service: MockEthereumNodeService(), for: EthereumNodeDomainService.self)
        XCTAssertNotNil(DomainRegistry.encryptionService)
        XCTAssertNotNil(DomainRegistry.externallyOwnedAccountRepository)
        XCTAssertNotNil(DomainRegistry.transactionRelayService)
        XCTAssertNotNil(DomainRegistry.ethereumNodeService)
    }

}
