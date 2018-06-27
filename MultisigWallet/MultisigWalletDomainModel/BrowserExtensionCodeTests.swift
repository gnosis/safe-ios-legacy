//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel

class BrowserExtensionCodeTests: XCTestCase {

    func test_canEcnodeAndDecode() throws {
        let str = """
            {"expirationDate": "2018-05-09T14:18:55+00:00",
              "signature": {
                "v": 27,
                "r":"test",
                "s":"me"
              }
            }
            """
        let dateFormatter = WalletDateFormatter()

        let date = dateFormatter.date(from: "2018-05-09T14:18:55+00:00")!
        let signature = RSVSignature(r: "test", s: "me", v: 27)
        let code = BrowserExtensionCode(expirationDate: date, signature: signature)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        let code2 = try decoder.decode(BrowserExtensionCode.self, from: str.data(using: .utf8)!)
        XCTAssertEqual(code, code2)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        let data = try encoder.encode(code)
        let code3 = try decoder.decode(BrowserExtensionCode.self, from: data)
        XCTAssertEqual(code, code3)
    }

}
