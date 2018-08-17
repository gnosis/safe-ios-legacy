//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe
import MultisigWalletDomainModel
import MultisigWalletImplementations
import Common

class HTTPTokenListServiceTests: XCTestCase {

    var tokenListService: HTTPTokenListService!

    override func setUp() {
        super.setUp()
        let config = try! AppConfig.loadFromBundle()!
        tokenListService = HTTPTokenListService(url: config.tokenListServiceURL, logger: MockLogger())
    }

    func test_canGetTokenItemsFromService() throws {
        let tokens = try tokenListService.items()
        XCTAssertFalse(tokens.isEmpty)
    }

}
