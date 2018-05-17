//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import EthereumImplementations
import EthereumKit

class EncryptionServiceTests: XCTestCase {

    let encryptionService = EncryptionService()

    func test_extensionCodeWithValidJson() {
        let json = JSON(extensionCode: extensionValidCode1)
        let code = ExtensionCode(json: json)!
        XCTAssertEqual(code.expirationDate, "2018-05-09T14:18:55+00:00")
        XCTAssertEqual(code.v, 27)
        XCTAssertEqual(code.r,
                       BInt("75119860711638973245538703589762310947594328712729260330312782656531560398776", radix: 10))
        XCTAssertEqual(code.s,
                       BInt("51392727032514077370236468627319183981033698696331563950328005524752791633785", radix: 10))
    }

    func test_extensionCodeWithInvalidJson() {
        let json = JSON(extensionCode: extensionInvalidCode1)
        let code = ExtensionCode(json: json)
        XCTAssertNil(code)
    }

    func test_address_whenValidCodeScanned_thenReturnsValidAddress() {
        guard let address = encryptionService.address(browserExtensionCode: extensionValidCode1.code) else {
            XCTFail("Couldn't decode extension code")
            return
        }
        XCTAssertEqual(address.uppercased(), extensionValidCode1.address.uppercased())
    }

    func test_address_whenInvalidCodeScanned_thenReturnedNil() {
        let address = encryptionService.address(browserExtensionCode: extensionInvalidCode1.code)
        XCTAssertNil(address)
    }

}

extension EncryptionServiceTests {

    private func JSON(extensionCode: BrowserExtensionCode) -> Any {
        let data = extensionCode.code.data(using: .utf8)!
        return try! JSONSerialization.jsonObject(with: data)
    }

}

struct BrowserExtensionCode {
    let code: String
    let address: String
}

let extensionValidCode1 = BrowserExtensionCode(
    code: """
    {"expirationDate": "2018-05-09T14:18:55+00:00",
      "signature": {
        "v": 27,
        "r":"75119860711638973245538703589762310947594328712729260330312782656531560398776",
        "s":"51392727032514077370236468627319183981033698696331563950328005524752791633785"
      }
    }
    """,
    address: "0xeBECD3521491D9D2CAA5111D23B6B764238DD09f"
)

let extensionInvalidCode1 = BrowserExtensionCode(
    code: """
    {"expirationDate": "2018-05-09T14:18:55+00:00",
      "signature": {
        "v": 27,
        "r":"75119860711638973245538703589762310947594328712729260330312782656531560398776"
      }
    }
    """,
    address: "0xeBECD3521491D9D2CAA5111D23B6B764238DD09f"
)
