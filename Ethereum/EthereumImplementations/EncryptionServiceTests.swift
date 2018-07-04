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
        encryptionService = EncryptionService(chainId: .mainnet)

        let (r, s, v) = try encryptionService.sign(message: message, privateKey: privateKey)
        XCTAssertEqual(r, "101211893217270431722518027522228002686666504049250244774157670632781156043183")
        XCTAssertEqual(s, "51602277827206092161359189523869407094850301206236947198082645428468309668322")
        XCTAssertEqual(v, 37)

        let signer = EIP155Signer(chainID: encryptionService.chainId.rawValue)
        let signature = signer.calculateSignature(r: BInt(r)!, s: BInt(s)!, v: BInt(v))

        // swiftlint:disable:next line_length
        XCTAssertEqual(signature.toHexString(), "dfc3e6c87132b3ef90b514041b7c77444d9d3f69b53c884e99fd37811b9dc9af7215daaf0fc1132306f7cb4223aa03e967ad6734f241bf17e0a33ced764db1e200")

        let publicKey = Crypto.generatePublicKey(data: pkData, compressed: true)
        let signedData = Crypto.hashSHA3_256(message.data(using: .utf8)!)
        let restoredPublicKey = Crypto.publicKey(signature: signature, of: signedData, compressed: true)!

        XCTAssertEqual(publicKey, restoredPublicKey)
    }

    var signature = RSVSignature(r: "197968319015768475474728412290891320396909873147159586006855444916116598112",
                                 s: "61819997756830335013150358111721476328157622718490157315818634400316888446796",
                                 v: 27)
    var transaction = EthTransaction(from: "0xf0C64662da29ebF76C7B9Bed3D7B02F2EAbD52B9",
                                     value: 0,
                                     // swiftlint:disable:next line_length
                                     data: "0x608060405234801561001057600080fd5b5060405161060a38038061060a833981018060405281019080805190602001909291908051820192919060200180519060200190929190805190602001909291908051906020019092919050505084848160008173ffffffffffffffffffffffffffffffffffffffff1614151515610116576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260248152602001807f496e76616c6964206d617374657220636f707920616464726573732070726f7681526020017f696465640000000000000000000000000000000000000000000000000000000081525060400191505060405180910390fd5b806000806101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff160217905550506000815111156101a35773ffffffffffffffffffffffffffffffffffffffff60005416600080835160208501846127105a03f46040513d6000823e600082141561019f573d81fd5b5050505b5050600081111561036d57600073ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff1614156102b7578273ffffffffffffffffffffffffffffffffffffffff166108fc829081150290604051600060405180830381858888f1935050505015156102b2576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260268152602001807f436f756c64206e6f74207061792073616665206372656174696f6e207769746881526020017f206574686572000000000000000000000000000000000000000000000000000081525060400191505060405180910390fd5b61036c565b6102d1828483610377640100000000026401000000009004565b151561036b576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260268152602001807f436f756c64206e6f74207061792073616665206372656174696f6e207769746881526020017f20746f6b656e000000000000000000000000000000000000000000000000000081525060400191505060405180910390fd5b5b5b5050505050610490565b600060608383604051602401808373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001828152602001925050506040516020818303038152906040527fa9059cbb000000000000000000000000000000000000000000000000000000007bffffffffffffffffffffffffffffffffffffffffffffffffffffffff19166020820180517bffffffffffffffffffffffffffffffffffffffffffffffffffffffff838183161783525050505090506000808251602084016000896127105a03f16040513d6000823e3d60008114610473576020811461047b5760009450610485565b829450610485565b8151158315171594505b505050509392505050565b61016b8061049f6000396000f30060806040526004361061004c576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680634555d5c91461008b5780635c60da1b146100b6575b73ffffffffffffffffffffffffffffffffffffffff600054163660008037600080366000845af43d6000803e6000811415610086573d6000fd5b3d6000f35b34801561009757600080fd5b506100a061010d565b6040518082815260200191505060405180910390f35b3480156100c257600080fd5b506100cb610116565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b60006002905090565b60008060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff169050905600a165627a7a723058206d69a7317ea208981c1c60405cb41a930548e3d5a04a8d497e29ddc5e60223f200290000000000000000000000002aab3573ecfd2950a30b75b6f3651b84f4e130da00000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000ab8c18e66135561676f0781555d05cf6b22024a30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f905e741cb1d800000000000000000000000000000000000000000000000000000000000001440ec78d9e00000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000003000000000000000000000000268bf7a7defcbfd7defd94f25f03f04b17efda310000000000000000000000006c60434fc786dec7fb03a7421e4014fa95da3e19000000000000000000000000daff896b02ee319d0f44af1533a0f48220283ade0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
                                     gas: "398260",
                                     gasPrice: "11000000000",
                                     nonce: 0)

    func test_whenExtractingContractAddress_thenVerifiesSignature() throws {
        let result = try encryptionService.contractAddress(from: signature, for: transaction)
        XCTAssertEqual(result, "0xF2Ce00Af37e883E03C54f3b56382Cc6F52fAE305")
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
