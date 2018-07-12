//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletImplementations
import MultisigWalletDomainModel

class InMemorySinglePortfolioRepositoryTests: XCTestCase {

    func test_savingAndRemoving() throws {
        let repo = InMemorySinglePortfolioRepository()
        let portfolio = Portfolio(id: repo.nextID())
        repo.save(portfolio)
        XCTAssertEqual(repo.portfolio(), portfolio)
        repo.remove(portfolio)
        XCTAssertNil(repo.portfolio())
    }

}
