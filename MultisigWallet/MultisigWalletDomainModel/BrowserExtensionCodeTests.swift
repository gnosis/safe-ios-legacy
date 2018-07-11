//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel
import CommonTestSupport
import MultisigWalletImplementations

class BrowserExtensionCodeTests: XCTestCase {

    let blockchainService = MockBlockchainDomainService()

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: blockchainService, for: BlockchainDomainService.self)
    }

    func test_canEcnodeAndDecode() throws {
        let dateFormatter = DateFormatter.networkDateFormatter

        let date = dateFormatter.date(from: "2018-05-09T14:18:55+00:00")!
        let signature = EthSignature(r: "test", s: "me", v: 27)
        let code = BrowserExtensionCode(
            expirationDate: date,
            signature: signature,
            extensionAddress: "address")
        blockchainService.browserExtensionAddress = "address"

        let code2 = try BrowserExtensionCode(json: BrowserExtensionFixture.testJSON)
        XCTAssertEqual(code, code2)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        let data = try encoder.encode(code)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        let code3 = try decoder.decode(BrowserExtensionCode.self, from: data)
        XCTAssertNil(code3.extensionAddress)
        XCTAssertEqual(code.expirationDate, code3.expirationDate)
        XCTAssertEqual(code.signature, code3.signature)
    }

}
