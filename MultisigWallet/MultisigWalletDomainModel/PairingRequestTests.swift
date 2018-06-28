//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel

class PairingRequestTests: XCTestCase {

    func test_canEcnodeAndDecode() throws {
        let str = """
            {
                "temporaryAuthorization": {
                    "expirationDate": "2018-05-09T14:18:55+00:00",
                    "signature": {
                        "v": 27,
                        "r":"test",
                        "s":"me"
                    }
                },
                "signature": {
                    "v" : 35,
                    "r" : "test",
                    "s" : "it"
                }
            }
            """
        let dateFormatter = WalletDateFormatter()

        let date = dateFormatter.date(from: "2018-05-09T14:18:55+00:00")!
        let codeSignature = RSVSignature(r: "test", s: "me", v: 27)
        let browserExtensionCode = BrowserExtensionCode(expirationDate: date, signature: codeSignature)

        let signature = RSVSignature(r: "test", s: "it", v: 35)

        let pairingRequest = PairingRequest(temporaryAuthorization: browserExtensionCode, signature: signature)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        let pairingRequest2 = try decoder.decode(PairingRequest.self, from: str.data(using: .utf8)!)
        XCTAssertEqual(pairingRequest, pairingRequest2)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        let data = try encoder.encode(pairingRequest)
        let pairingRequest3 = try decoder.decode(PairingRequest.self, from: data)
        XCTAssertEqual(pairingRequest, pairingRequest3)
    }

}
