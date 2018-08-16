//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletImplementations

class MockTokenListServiceTests: XCTestCase {

    func test_canParseTestJson() throws {
        let tokenService = MockTokenListService()
        let tokens = try tokenService.tokens()
        XCTAssertEqual(tokens.count, 7)
        XCTAssertEqual(tokens[2].address.value, "0x5f92161588c6178130ede8cbdc181acec66a9731")
        XCTAssertEqual(tokens[2].name, "Gnosis")
        XCTAssertEqual(tokens[2].code, "GNO")
        XCTAssertEqual(tokens[2].decimals, 18)
        // swiftlint:disable:next line_length
        XCTAssertEqual(tokens[2].logoUrl, "https://github.com/TrustWallet/tokens/blob/master/images/0x6810e776880c02933d47db1b9fc05908e5386b96.png?raw=true")
    }

}
