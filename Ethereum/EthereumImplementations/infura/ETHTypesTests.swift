//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import EthereumImplementations
import BigInt

class ETHTypesTests: XCTestCase {

    func test_whenCondition_thenResult() {
        let maxUInt256 = UInt256(BigUInt(2).power(256) - 1)
        let value = UInt256(hex: maxUInt256.hexString)
        XCTAssertEqual(value, maxUInt256)
    }

}
