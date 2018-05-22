//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import EthereumImplementations
import EthereumKit

class EncryptionServiceTests: XCTestCase {

    let encryptionService = EncryptionService()

    func test_extensionCodeWithValidJson() {
        let json = JSON(extensionCode: QRCode.validCode1)
        let code = ExtensionCode(json: json)!
        XCTAssertEqual(code.expirationDate, "2018-05-09T14:18:55+00:00")
        XCTAssertEqual(code.v, 27)
        XCTAssertEqual(code.r,
                       BInt("75119860711638973245538703589762310947594328712729260330312782656531560398776", radix: 10))
        XCTAssertEqual(code.s,
                       BInt("51392727032514077370236468627319183981033698696331563950328005524752791633785", radix: 10))
    }

    func test_extensionCodeWithInvalidJson() {
        let json = JSON(extensionCode: QRCode.invalidCode1)
        let code = ExtensionCode(json: json)
        XCTAssertNil(code)
    }

    func test_address_whenValidCodeScanned_thenReturnsValidAddress() {
        guard let address1 = encryptionService.address(browserExtensionCode: QRCode.validCode1.code) else {
            XCTFail("Couldn't decode extension code for address 1")
            return
        }
        XCTAssertEqual(address1.uppercased(), QRCode.validCode1.address.uppercased())

        guard let address2 = encryptionService.address(browserExtensionCode: QRCode.validCode2.code) else {
            XCTFail("Couldn't decode extension code for address 2")
            return
        }
        XCTAssertEqual(address2.uppercased(), QRCode.validCode2.address.uppercased())
    }

    func test_address_whenInvalidCodeScanned_thenReturnedNil() {
        let address = encryptionService.address(browserExtensionCode: QRCode.invalidCode1.code)
        XCTAssertNil(address)
    }

}

extension EncryptionServiceTests {

    private func JSON(extensionCode: QRCode) -> Any {
        let data = extensionCode.code.data(using: .utf8)!
        return try! JSONSerialization.jsonObject(with: data)
    }

}

struct QRCode {
    let code: String
    let address: String

    static let validCode1 = QRCode(
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

    static let validCode2 = QRCode(
        code: """
            {"expirationDate" : "2018-05-17T13:47:00+00:00",
              "signature": {
                "v": 27,
                "r":"79425995431864040500581522255237765710685762616259654871112297909982135982384",
                "s":"1777326029228985739367131500591267170048497362640342741198949880105318675913"
              }
            }
            """,
        address: "0xeBECD3521491D9D2CAA5111D23B6B764238DD09f"
    )

    static let invalidCode1 = QRCode(
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

}
