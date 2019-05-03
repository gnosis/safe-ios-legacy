//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel

class TokenListItemTests: XCTestCase {

    var tokenListItem: TokenListItem!

    override func setUp() {
        super.setUp()
        tokenListItem = TokenListItem(token: Token.Ether, status: .regular, canPayTransactionFee: true)
    }

    func test_whenCreated_thenHasAllData() {
        XCTAssertEqual(tokenListItem.id.id, "0x0000000000000000000000000000000000000000")
        XCTAssertEqual(tokenListItem.token, Token.Ether)
        XCTAssertEqual(tokenListItem.status, .regular)
        XCTAssertEqual(tokenListItem.canPayTransactionFee, true)
    }

    func test_blacklisting() {
        tokenListItem.blacklist()
        XCTAssertEqual(tokenListItem.status, .blacklisted)
    }

    func test_whitelisting() {
        tokenListItem.whitelist()
        XCTAssertEqual(tokenListItem.status, .whitelisted)
    }

    func test_updatingSortingId() {
        XCTAssertEqual(tokenListItem.sortingId, nil)
        tokenListItem.updateSortingId(with: 10)
        XCTAssertEqual(tokenListItem.sortingId, 10)
    }

}
