//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletApplication
import MultisigWalletDomainModel
import CommonTestSupport

class PairingWithBrowserExtensionTests: BaseWalletApplicationServiceTests {

    func test_whenAddingBrowserExtensionOwner_thenWorksProperly() throws {
        ethereumService.browserExtensionAddress = Address.extensionAddress.value
        givenDraftWallet()
        try service.addBrowserExtensionOwner(address: Address.extensionAddress.value,
                                             browserExtensionCode: BrowserExtensionFixture.testJSON)
        XCTAssertTrue(ethereumService.didSign)
        XCTAssertTrue(notificationService.didPair)
        XCTAssertNotNil(service.ownerAddress(of: .browserExtension))
    }

    func test_whenAddingBrowserExtensionOwnerWithNetworkFailure_thenThrowsError() throws {
        givenDraftWallet()
        notificationService.shouldThrow = true
        XCTAssertThrowsError(
            try service.addBrowserExtensionOwner(address: Address.extensionAddress.value,
                                                 browserExtensionCode: BrowserExtensionFixture.testJSON))
    }

    func test_canEncodeAndDecodeBrowserExtensionCode() throws {
        let dateFormatter = DateFormatter.networkDateFormatter

        let date = dateFormatter.date(from: "2018-05-09T14:18:55+00:00")!
        let signature = EthSignature(r: "test", s: "me", v: 27)
        let code = BrowserExtensionCode(
            expirationDate: date,
            signature: signature,
            extensionAddress: "address")

        ethereumService.browserExtensionAddress = "address"

        let code2 = service.browserExtensionCode(from: BrowserExtensionFixture.testJSON)
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
