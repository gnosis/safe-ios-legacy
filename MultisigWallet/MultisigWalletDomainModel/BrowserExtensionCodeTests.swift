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
        let signature = Signature(v: 27, r: "test", s: "me")
        let code = BroewserExtensionCode(expirationDate: date, signature: signature)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        let code2 = try decoder.decode(BroewserExtensionCode.self, from: str.data(using: .utf8)!)
        XCTAssertEqual(code, code2)

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        let data = try encoder.encode(code)
        let code3 = try decoder.decode(BroewserExtensionCode.self, from: data)
        XCTAssertEqual(code, code3)
    }

}
