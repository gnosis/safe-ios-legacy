//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import EthereumImplementations
import BigInt

class BigInt_HexTests: XCTestCase {

    func test_whenCondition_thenResult() {
        let int = BigInt(2).power(256) - 1
        let value = BigInt(hex: int.hexString)
        XCTAssertEqual(value, int)
    }

}
