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
        XCTAssertEqual(repository.all().count, 1)
        let gno = Token(code: "GNO", name: "Gnosis", decimals: 18, address: Address("0xSOME"), logoUrl: "SOME")
        let item2 = TokenListItem(token: gno, status: .regular)
        repository.save(item2)
        let all = repository.all()
        XCTAssertEqual(all.count, 2)
        XCTAssertEqual(all[0].token, eth)
        XCTAssertEqual(all[0].status, .whitelisted)
        XCTAssertEqual(all[1].token, gno)
        XCTAssertEqual(all[1].status, .regular)
        repository.remove(item)
        XCTAssertNil(repository.find(id: eth.id))
        XCTAssertEqual(repository.all().count, 1)
    }

}
