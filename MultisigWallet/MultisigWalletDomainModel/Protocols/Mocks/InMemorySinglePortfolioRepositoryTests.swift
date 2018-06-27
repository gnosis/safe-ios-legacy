//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletImplementations
import MultisigWalletDomainModel

class InMemorySinglePortfolioRepositoryTests: XCTestCase {

    func test_savingAndRemoving() throws {
        let repo = InMemorySinglePortfolioRepository()
        let portfolio = try Portfolio(id: repo.nextID())
        try repo.save(portfolio)
        XCTAssertEqual(try repo.portfolio(), portfolio)
        try repo.remove(portfolio)
        XCTAssertNil(try repo.portfolio())
    }

}
