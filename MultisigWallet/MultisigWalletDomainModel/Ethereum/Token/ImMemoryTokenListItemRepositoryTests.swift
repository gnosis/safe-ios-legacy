//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel

class ImMemoryTokenListItemRepositoryTests: XCTestCase {

    func test_allMethods() {
        let repository = InMemoryTokenListItemRepository()
        let eth = Token.Ether
        let item = TokenListItem(token: eth, status: .whitelisted)
        repository.save(item)
        XCTAssertEqual(repository.find(id: eth.id), item)
        repository.remove(item)
        XCTAssertNil(repository.find(id: eth.id))
    }

}
