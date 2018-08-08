//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel

class DataInitWithHexTest: XCTestCase {

    func test_ethDataConversion() {
        XCTAssertEqual(Data(ethHex: "0x"), Data())
        XCTAssertEqual(Data(ethHex: "0X"), Data())
        XCTAssertEqual(Data(ethHex: "0xa"), Data(bytes: [0x0a]))
        XCTAssertEqual(Data(ethHex: "0xbbb"), Data(bytes: [0x0b, 0xbb]))
        XCTAssertEqual(Data(ethHex: "0x1234"), Data(bytes: [0x12, 0x34]))
    }

}
