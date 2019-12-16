//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel
import MultisigWalletImplementations
import BigInt

class GnosisSafeContractProxyTests: EthereumContractProxyBaseTests {

    // this is a sample setupData taken from the API response
    // swiftlint:disable:next line_length
    let data = Data(hex: "0xb63e800d00000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001a0000000000000000000000000d5d82b6addc9027b22dca772aa68d5d74cdbdf44000000000000000000000000b3a4bc89d8517e0e2c9b66703d09d3029ffa1e6d0000000000000000000000000000000000000000000000000000000000022b2e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000000000000000000008e70f49bdfabd36da93f5bab1b7170a49d3fd3f900000000000000000000000072e3d79b0eed7d4996bef38acfd700f45a0df16e000000000000000000000000f6767c1d215b3345b77eebd642710426f645c4ce0000000000000000000000002fb448d42a0e77fab64aa9575dcd6fc7650f8aa600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")

    let actualEncryptionService = EncryptionService(chainId: .any, ethereumService: EthereumKitEthereumService())
    let contract = GnosisSafeContractProxy()
    let owners = [Address("0x8e70f49bdfabd36da93f5bab1b7170a49d3fd3f9"),
                  Address("0x72e3d79b0eed7d4996bef38acfd700f45a0df16e"),
                  Address("0xf6767c1d215b3345b77eebd642710426f645c4ce"),
                  Address("0x2fb448d42a0e77fab64aa9575dcd6fc7650f8aa6")]
    let paymentToken = Address("0xb3a4bc89d8517e0e2c9b66703d09d3029ffa1e6d")
    let fallbackHandler = Address("0xd5d82b6addc9027b22dca772aa68d5d74cdbdf44")

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: actualEncryptionService, for: EncryptionDomainService.self)
    }

    func test_decodeSetup() {
        let arguments = contract.decodeSetup(from: data)
        XCTAssertNotNil(arguments)
        XCTAssertEqual(arguments?.owners, owners)
        XCTAssertEqual(arguments?.threshold, 2)
        XCTAssertEqual(arguments?.data, Data())
        XCTAssertEqual(arguments?.fallbackHandler, fallbackHandler)
        XCTAssertEqual(arguments?.to, Address.zero)
        XCTAssertEqual(arguments?.paymentToken, paymentToken)
        XCTAssertEqual(arguments?.payment, 142_126)
        XCTAssertEqual(arguments?.paymentReceiver, Address.zero)
    }

    func test_encodeSetup() {
        let encoded = contract.setup(owners: owners,
                                     threshold: 2,
                                     to: Address.zero,
                                     data: Data(),
                                     fallbackHandler: fallbackHandler,
                                     paymentToken: paymentToken,
                                     payment: 142_126,
                                     paymentReceiver: Address.zero)
        XCTAssertEqual(encoded, data, "Expected \(encoded.toHexString())")
    }

}
