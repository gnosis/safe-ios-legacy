//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import EthereumDomainModel

class EtherTests: XCTestCase {

    func test_whenEtherCreatedWithHex_thenItHasCorrectAmount() {
        XCTAssertEqual(Ether(hexAmount: "0x123456"), Ether(amount: 0x123456))
        XCTAssertEqual(Ether(hexAmount: "1122334455667788"), Ether(amount: 0x1122334455667788)) // Int is 8 bytes
    }

}
