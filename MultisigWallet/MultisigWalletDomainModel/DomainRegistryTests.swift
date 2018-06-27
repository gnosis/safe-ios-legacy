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
        DomainRegistry.put(service: MockBlockchainDomainService(), for: BlockchainDomainService.self)
        DomainRegistry.put(service: MockNotificationService(), for: NotificationDomainService.self)
        XCTAssertNotNil(DomainRegistry.walletRepository)
        XCTAssertNotNil(DomainRegistry.portfolioRepository)
        XCTAssertNotNil(DomainRegistry.blockchainService)
        XCTAssertNotNil(DomainRegistry.notificationService)
    }

}
