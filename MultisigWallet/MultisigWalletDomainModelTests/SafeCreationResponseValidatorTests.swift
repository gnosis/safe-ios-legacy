//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel
import MultisigWalletImplementations

class SafeCreationResponseValidatorTests: XCTestCase {

    let validator = SafeCreationResponseValidator()
    let metadata = SafeContractMetadata.testMetadata()
    let request = SafeCreationRequest.testRequest()
    let encryptionService = EncryptionService(chainId: .any, ethereumService: EthereumKitEthereumService())
    let metadataRepo = InMemorySafeContractMetadataRepository(metadata: SafeContractMetadata.testMetadata())

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: metadataRepo, for: SafeContractMetadataRepository.self)
        DomainRegistry.put(service: encryptionService, for: EncryptionDomainService.self)
    }

    func test_paymentToken() {
        let wrongPaymentToken = Address.testAccount4.value
        assertThrows(.invalidPaymentToken,
                     .init(safe: Address.safeAddress.value,
                           masterCopy: Address.testAccount4.value,
                           proxyFactory: Address.testAccount2.value,
                           paymentToken: wrongPaymentToken,
                           payment: 100,
                           paymentReceiver: Address.zero.value,
                           setupData: "0xa12345",
                           gasEstimated: 50,
                           gasPriceEstimated: 2))
    }

    func test_masterCopy() {
        let wrongMasterCopy = Address.testAccount1.value
        assertThrows(.invalidMasterCopy,
                     .init(safe: Address.safeAddress.value,
                           masterCopy: wrongMasterCopy,
                           proxyFactory: Address.testAccount2.value,
                           paymentToken: request.paymentToken,
                           payment: 100,
                           paymentReceiver: Address.zero.value,
                           setupData: "0xa12345",
                           gasEstimated: 50,
                           gasPriceEstimated: 2))
    }

    func test_proxyFactory() {
        let wrongProxyFactory = Address.testAccount1.value
        assertThrows(.invalidProxyFactory,
                     .init(safe: Address.safeAddress.value,
                           masterCopy: Address.testAccount4.value,
                           proxyFactory: wrongProxyFactory,
                           paymentToken: request.paymentToken,
                           payment: 100,
                           paymentReceiver: Address.zero.value,
                           setupData: "0xa12345",
                           gasEstimated: 50,
                           gasPriceEstimated: 2))
    }

    func test_wrongPaymentReceiver() {
        let wrongPaymentReceiver = Address.testAccount4.value
        assertThrows(.invalidPaymentReceiver,
                     .init(safe: Address.safeAddress.value,
                           masterCopy: Address.testAccount4.value,
                           proxyFactory: Address.testAccount2.value,
                           paymentToken: request.paymentToken,
                           payment: 100,
                           paymentReceiver: wrongPaymentReceiver,
                           setupData: "0xa12345",
                           gasEstimated: 50,
                           gasPriceEstimated: 2))
    }

    func test_paymentReceiver_txOriginAddressZero() {
        let baseResponse = SafeCreationRequest.Response(safe: Address.safeAddress.value, // will be replaced
                                                        masterCopy: Address.testAccount4.value,
                                                        proxyFactory: Address.testAccount2.value,
                                                        paymentToken: request.paymentToken,
                                                        payment: 100,
                                                        paymentReceiver: Address.zero.value, // tested value
                                                        setupData: SafeCreationRequest.setupData(payment: 100),
                                                        gasEstimated: 50,
                                                        gasPriceEstimated: 2)
        XCTAssertNoThrow(try validator.validate(.testResponse(from: baseResponse, request), request: request))
    }

    func test_paymentReceiver_funderAddress() {
        let setupData = SafeCreationRequest.setupData(payment: 100, receiver: metadata.safeFunderAddress)
        let baseResponse = SafeCreationRequest.Response(safe: Address.safeAddress.value, // will be replaced
                                                        masterCopy: Address.testAccount4.value,
                                                        proxyFactory: Address.testAccount2.value,
                                                        paymentToken: request.paymentToken,
                                                        payment: 100,
                                                        paymentReceiver: metadata.safeFunderAddress.value,
                                                        setupData: setupData,
                                                        gasEstimated: 50,
                                                        gasPriceEstimated: 2)
        XCTAssertNoThrow(try validator.validate(.testResponse(from: baseResponse, request), request: request))
    }

    func test_setupData() {
        let wrongSetupData = "0xa12345"
        assertThrows(.invalidSetupData,
                     .init(safe: Address.safeAddress.value,
                           masterCopy: Address.testAccount4.value,
                           proxyFactory: Address.testAccount2.value,
                           paymentToken: request.paymentToken,
                           payment: 100,
                           paymentReceiver: Address.zero.value,
                           setupData: wrongSetupData,
                           gasEstimated: 50,
                           gasPriceEstimated: 2))
    }

    func test_wrongSafeAddress() {
        assertThrows(.invalidAddress,
                     .init(safe: Address.safeAddress.value,
                           masterCopy: Address.testAccount4.value,
                           proxyFactory: Address.testAccount2.value,
                           paymentToken: request.paymentToken,
                           payment: 100,
                           paymentReceiver: Address.zero.value,
                           setupData: SafeCreationRequest.setupData(payment: 100),
                           gasEstimated: 50,
                           gasPriceEstimated: 2))
    }

    func test_actualSampleData() throws {
        // swiftlint:disable line_length
        let requestJSON = """
        {
            "paymentToken": "0xb3a4Bc89d8517E0e2C9B66703d09D3029ffa1e6d",
            "owners": [
                "0x8E70F49bdfaBD36Da93f5Bab1B7170A49D3fD3f9",
                "0x72E3d79B0eED7d4996bEf38acFD700f45A0dF16e",
                "0xF6767C1D215b3345B77Eebd642710426f645C4cE",
                "0x2fB448d42A0e77fAb64aa9575Dcd6fc7650F8AA6"
            ],
            "saltNonce": "1",
            "threshold": 2
        }
"""
        let responseJSON = """
        {
            "safe": "0x2817DF07bfA125f438312d0BcF6aef2FBF526bc0",
            "masterCopy": "0xb6029EA3B2c51D09a50B53CA8012FeEB05bDa35A",
            "proxyFactory": "0x12302fE9c02ff50939BaAaaf415fc226C078613C",
            "paymentToken": "0xb3a4Bc89d8517E0e2C9B66703d09D3029ffa1e6d",
            "payment": "18537",
            "paymentReceiver": "0x0000000000000000000000000000000000000000",
            "setupData": "0xa97ab18a00000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000180000000000000000000000000b3a4bc89d8517e0e2c9b66703d09d3029ffa1e6d0000000000000000000000000000000000000000000000000000000000004869000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000000000000000000008e70f49bdfabd36da93f5bab1b7170a49d3fd3f900000000000000000000000072e3d79b0eed7d4996bef38acfd700f45a0df16e000000000000000000000000f6767c1d215b3345b77eebd642710426f645c4ce0000000000000000000000002fb448d42a0e77fab64aa9575dcd6fc7650f8aa600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
            "gasEstimated": "370736",
            "gasPriceEstimated": "1000000001"
        }
"""
        let metadata = SafeContractMetadata(multiSendContractAddress: Address("0xe74d6af1670fb6560dd61ee29eb57c7bc027ce4e"),
                                            proxyFactoryAddress: Address("0x12302fE9c02ff50939BaAaaf415fc226C078613C"),
                                            safeFunderAddress: Address("0xd9e09beaEb338d81a7c5688358df0071d4988115"),
                                            masterCopy: [MasterCopyMetadata(address: Address("0xb6029EA3B2c51D09a50B53CA8012FeEB05bDa35A"),
                                                                            version: "1.0.0",
                                                                            txTypeHash: Data(ethHex: "0xbb8310d486368db6bd6f849402fdd73ad53d316b5a4b2644ad6efe0f941286d8"),
                                                                            domainSeparatorHash: Data(ethHex: "0x035aff83d86937d35b32e04f0ddc6ff469290eef2f1b692d8a815c89404d4749"),
                                                                            proxyCode: Data(ethHex: "0x608060405234801561001057600080fd5b506040516020806101a88339810180604052602081101561003057600080fd5b8101908080519060200190929190505050600073ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff1614156100c7576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260248152602001806101846024913960400191505060405180910390fd5b806000806101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff16021790555050606e806101166000396000f3fe608060405273ffffffffffffffffffffffffffffffffffffffff600054163660008037600080366000845af43d6000803e6000811415603d573d6000fd5b3d6000f3fea165627a7a723058201e7d648b83cfac072cbccefc2ffc62a6999d4a050ee87a721942de1da9670db80029496e76616c6964206d617374657220636f707920616464726573732070726f7669646564"))],
                                            multiSend: [])
        // swiftlint:enable line_length
        
        let repo = InMemorySafeContractMetadataRepository(metadata: metadata)
        DomainRegistry.put(service: repo, for: SafeContractMetadataRepository.self)
        
        let request = try JSONDecoder().decode(SafeCreationRequest.self,
                                               from: requestJSON.data(using: .utf8)!)
        let response = try JSONDecoder().decode(SafeCreationRequest.Response.self,
                                                from: responseJSON.data(using: .utf8)!)

        XCTAssertNoThrow(try validator.validate(response, request: request))
    }

}

extension SafeCreationResponseValidatorTests {

    private func assertThrows(_ expectedError: SafeCreationValidationError,
                              _ response: SafeCreationRequest.Response,
                              line: UInt = #line) {
        XCTAssertThrowsError(try validator.validate(response, request: request),
                             "Wrong or no error",
                             line: line) { actualError in
            XCTAssertTrue(actualError as? SafeCreationValidationError == expectedError,
                          String(describing: actualError),
                          line: line)
        }
    }

}
