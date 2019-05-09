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
    let data = Data(hex: "0xa97ab18a00000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000180000000000000000000000000b3a4bc89d8517e0e2c9b66703d09d3029ffa1e6d00000000000000000000000000000000000000000000000000000000000090d200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000d1cd8b1ac0639e5e21d4d967812c7b1384adb2de000000000000000000000000a1c0e4a764183a7667ffb21a628383de9d63357e000000000000000000000000e8213667a9da1493f85b0d65d9a244c21a858506000000000000000000000000f077f28bceb8e0e85b69f9926298ccf015eb556a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")

    let actualEncryptionService = EncryptionService(chainId: .any, ethereumService: EthereumKitEthereumService())
    let contract = GnosisSafeContractProxy()
    let owners = [Address("0xd1cd8b1ac0639e5e21d4d967812c7b1384adb2de"),
                  Address("0xa1c0e4a764183a7667ffb21a628383de9d63357e"),
                  Address("0xe8213667a9da1493f85b0d65d9a244c21a858506"),
                  Address("0xf077f28bceb8e0e85b69f9926298ccf015eb556a")]
    let paymentToken = Address("0xb3a4bc89d8517e0e2c9b66703d09d3029ffa1e6d")

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
        XCTAssertEqual(arguments?.to, Address.zero)
        XCTAssertEqual(arguments?.paymentToken, paymentToken)
        XCTAssertEqual(arguments?.payment, 37_074)
        XCTAssertEqual(arguments?.paymentReceiver, Address.zero)
    }

    func test_encodeSetup() {
        let encoded = contract.setup(owners: owners,
                                     threshold: 2,
                                     to: Address.zero,
                                     data: Data(),
                                     paymentToken: paymentToken,
                                     payment: 37_074,
                                     paymentReceiver: Address.zero)
        XCTAssertEqual(encoded, data, "Expected \(encoded.toHexString())")
    }

}
