//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import EthereumImplementations
import EthereumApplication
import EthereumKit
import Common
import EthereumDomainModel
import CryptoSwift

class EncryptionServiceTests: XCTestCase {

    var encryptionService = EncryptionService()

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: MockLogger(), for: Logger.self)
    }

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

    func test_whenMnemonicNotEnough_thenThrows() {
        let ethereumService = MockEthereumService()
        ethereumService.mnemonic = []
        encryptionService = EncryptionService(chainId: .mainnet, ethereumService: ethereumService)
        XCTAssertThrowsError(try encryptionService.generateExternallyOwnedAccount())
    }

    func test_whenExternallyOwnedAccountCreated_thenItIsCorrect() throws {
        let expectedAccount = ExternallyOwnedAccount.testAccount
        let ethereumService = CustomWordsEthereumService(words: expectedAccount.mnemonic.words)
        encryptionService = EncryptionService(chainId: .mainnet, ethereumService: ethereumService)

        let account = try encryptionService.generateExternallyOwnedAccount()

        XCTAssertEqual(account, expectedAccount)
        XCTAssertEqual(account.address, expectedAccount.address)
        XCTAssertEqual(account.mnemonic, expectedAccount.mnemonic)
        XCTAssertEqual(account.privateKey, expectedAccount.privateKey)
        XCTAssertEqual(account.publicKey, expectedAccount.publicKey)
    }

    func test_whenSigningMessage_thenSignatureIsCorrect() throws {
        let pkData = Data(hex: "d0d3ae306602070917c456b61d88bee9dc74edb5853bb87b1c13e5bfa2c3d0d9")
        let privateKey = EthereumDomainModel.PrivateKey(data: pkData)
        let message = "Gnosis"

        let signature = try encryptionService.sign(message: message, privateKey: privateKey)

        // swiftlint:disable:next line_length
        XCTAssertEqual(signature.toHexString(), "dfc3e6c87132b3ef90b514041b7c77444d9d3f69b53c884e99fd37811b9dc9af7215daaf0fc1132306f7cb4223aa03e967ad6734f241bf17e0a33ced764db1e200")

        let publicKey = Crypto.generatePublicKey(data: pkData, compressed: true)
        let signedData = Crypto.hashSHA3_256(message.data(using: .utf8)!)
        let restoredPublicKey = Crypto.publicKey(signature: signature, of: signedData, compressed: true)!

        XCTAssertEqual(publicKey, restoredPublicKey)
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


class CustomWordsEthereumService: EthereumKitEthereumService {

    let words: [String]

    init(words: [String]) {
        self.words = words
    }

    override func createMnemonic() -> [String] {
        return words
    }

}

class MockEthereumService: EthereumService {

    var mnemonic = [String]()
    var seed = Data()
    var privateKey = Data()
    var publicKey = Data()
    var address = "address"

    func createMnemonic() -> [String] {
        return mnemonic
    }

    func createSeed(mnemonic: [String]) -> Data {
        return seed
    }

    func createPrivateKey(seed: Data, network: EIP155ChainId) -> Data {
        return privateKey
    }

    func createPublicKey(privateKey: Data) -> Data {
        return publicKey
    }

    func createAddress(publicKey: Data) -> String {
        return address
    }

}
