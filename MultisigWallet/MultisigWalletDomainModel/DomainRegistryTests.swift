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
        XCTAssertNotNil(DomainRegistry.walletRepository)
        XCTAssertNotNil(DomainRegistry.portfolioRepository)
    }

}
