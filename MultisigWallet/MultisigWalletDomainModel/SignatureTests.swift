//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel

class SignatureTests: XCTestCase {

    func test_canEcnodeAndDecode() throws {
        let str =
            """
                { "v" : 35, "r" : "test", "s" : "it" }
            """
        let signature = Signature(v: 35, r: "test", s: "it")

        let decoder = JSONDecoder()
        let signature2 = try decoder.decode(Signature.self, from: str.data(using: .utf8)!)
        XCTAssertEqual(signature, signature2)

        let encoder = JSONEncoder()
        let data = try encoder.encode(signature)
        let signature3 = try decoder.decode(Signature.self, from: data)
        XCTAssertEqual(signature, signature3)
    }

}
