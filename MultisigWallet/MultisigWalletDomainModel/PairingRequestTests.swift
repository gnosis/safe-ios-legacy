//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel
import CommonTestSupport

class PairingRequestTests: XCTestCase {

    func test_canEcnodeAndDecode() throws {
        let dateFormatter = DateFormatter.networkDateFormatter
        let date = dateFormatter.date(from: "2018-05-09T14:18:55+00:00")!
        let codeSignature = RSVSignature(r: "test", s: "me", v: 27)
        let browserExtensionCode = BrowserExtensionCode(
            expirationDate: date, signature: codeSignature, extensionAddress: nil)

        let signature = RSVSignature(r: "test", s: "it", v: 35)

        let pairingRequest = PairingRequest(
            temporaryAuthorization: browserExtensionCode,
            signature: signature,
            deviceOwnerAddress: nil)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        let pairingRequest2 = try decoder.decode(
            PairingRequest.self,
            from: PairingRequestFixture.testJSON.data(using: .utf8)!)
        XCTAssertEqual(pairingRequest, pairingRequest2)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        let data = try encoder.encode(pairingRequest)
        let pairingRequest3 = try decoder.decode(PairingRequest.self, from: data)
        XCTAssertEqual(pairingRequest, pairingRequest3)
    }

}
