//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
import MultisigWalletDomainModel
@testable import MultisigWalletImplementations

class WalletIDListTests: XCTestCase {

    func test_serialization() {
        // "" -> []
        XCTAssertEqual(WalletIDList(serializedString: ""), WalletIDList([]))
        // "," -> []
        XCTAssertEqual(WalletIDList(serializedString: ","), WalletIDList([]))
        // "abc" -> ["abc"]
        XCTAssertEqual(WalletIDList(serializedString: "abc"), WalletIDList([WalletID("abc")]))
        // ",,,abc,,," -> ["abc"]
        XCTAssertEqual(WalletIDList(serializedString: ",,,abc,,,"), WalletIDList([WalletID("abc")]))
        // ",abc" -> "abc"
        XCTAssertEqual(WalletIDList([WalletID(""), WalletID("abc")]).serializedValue as? String, "abc")
    }

}
