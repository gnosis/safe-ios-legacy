//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel

class TokenListItemTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func test_whenCreated_thenHasAllData() {
        let eth = Token.Ether
        let tokenListItem = TokenListItem(token: eth, status: .regular)
        XCTAssertEqual(tokenListItem.id.id, "0x0000000000000000000000000000000000000000")
        XCTAssertEqual(tokenListItem.token, eth)
        XCTAssertEqual(tokenListItem.status, .regular)
    }

}
