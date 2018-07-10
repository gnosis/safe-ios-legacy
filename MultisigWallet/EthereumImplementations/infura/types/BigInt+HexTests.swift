//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import EthereumImplementations
import BigInt

class BigInt_HexTests: XCTestCase {

    func test_bigInt() {
        let int = BigInt(2).power(256) - 1
        let intValue = BigInt(hex: int.hexString)
        XCTAssertEqual(intValue, int)

        let uint = BigUInt(2).power(256) - 1
        let uintValue = BigUInt(hex: uint.hexString)
        XCTAssertEqual(uintValue, uint)
    }

}
