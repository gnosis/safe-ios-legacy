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
        DomainRegistry.put(service: InMemoryAccountRepository(), for: AccountRepository.self)
        DomainRegistry.put(service: InMemoryExternallyOwnedAccountRepository(),
                           for: ExternallyOwnedAccountRepository.self)
        DomainRegistry.put(service: InMemoryTransactionRepository(), for: TransactionRepository.self)
        DomainRegistry.put(service: InMemoryTokenListItemRepository(), for: TokenListItemRepository.self)

        DomainRegistry.put(service: MockNotificationService(), for: NotificationDomainService.self)
        DomainRegistry.put(service: MockPushTokensDomainService(), for: PushTokensDomainService.self)
        DomainRegistry.put(service: MockEncryptionService(), for: EncryptionDomainService.self)
        DomainRegistry.put(service: MockTransactionRelayService(averageDelay: 0.1, maxDeviation: 0.1),
                           for: TransactionRelayDomainService.self)
        DomainRegistry.put(service: MockEthereumNodeService(), for: EthereumNodeDomainService.self)
        DomainRegistry.put(service: MockTokenListService(), for: TokenListDomainService.self)
        DomainRegistry.put(service: MockSynchronisationDomainService(), for: SynchronisationDomainService.self)
        DomainRegistry.put(service: MockEventPublisher(), for: EventPublisher.self)

        XCTAssertNotNil(DomainRegistry.walletRepository)
        XCTAssertNotNil(DomainRegistry.portfolioRepository)
        XCTAssertNotNil(DomainRegistry.accountRepository)
        XCTAssertNotNil(DomainRegistry.externallyOwnedAccountRepository)
        XCTAssertNotNil(DomainRegistry.transactionRepository)
        XCTAssertNotNil(DomainRegistry.tokenListItemRepository)

        XCTAssertNotNil(DomainRegistry.notificationService)
        XCTAssertNotNil(DomainRegistry.pushTokensService)
        XCTAssertNotNil(DomainRegistry.encryptionService)
        XCTAssertNotNil(DomainRegistry.transactionRelayService)
        XCTAssertNotNil(DomainRegistry.ethereumNodeService)
        XCTAssertNotNil(DomainRegistry.tokenListService)
        XCTAssertNotNil(DomainRegistry.syncService)
        XCTAssertNotNil(DomainRegistry.eventPublisher)
    }

}
