//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
import BigInt
@testable import MultisigWalletDomainModel

class StringifiedBigIntTests: XCTestCase {

    func test_stringifiedJSON() throws {
        XCTAssertEqual(try JSONDecoder().decode([StringifiedBigInt].self, from: "[\"1\"]".data(using: .utf8)!), [1])
        XCTAssertEqual(try JSONEncoder().encode([StringifiedBigInt(1)]), "[\"1\"]".data(using: .utf8)!)
    }

}
