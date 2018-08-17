//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletImplementations

class MockTokenListServiceTests: XCTestCase {

    func test_canParseTestJson() throws {
        let tokenService = MockTokenListService()
        let items = try tokenService.items()
        XCTAssertEqual(items.count, 7)
        let token = items[2].token
        XCTAssertEqual(items[2].status, .whitelisted)
        XCTAssertEqual(token.address.value, "0x5f92161588c6178130ede8cbdc181acec66a9731")
        XCTAssertEqual(token.name, "Gnosis")
        XCTAssertEqual(token.code, "GNO")
        XCTAssertEqual(token.decimals, 18)
        // swiftlint:disable:next line_length
        XCTAssertEqual(token.logoUrl, "https://github.com/TrustWallet/tokens/blob/master/images/0x6810e776880c02933d47db1b9fc05908e5386b96.png?raw=true")
        XCTAssertEqual(items[1].status, .regular)
    }

}
