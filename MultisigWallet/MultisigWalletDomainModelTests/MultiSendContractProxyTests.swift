//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel
import MultisigWalletImplementations

class MultiSendContractProxyTests: XCTestCase {

    func test_decode_v1() {
        DomainRegistry.put(service: EncryptionService(), for: EncryptionDomainService.self)
        let ownerProxy = SafeOwnerManagerContractProxy(.safeAddress)
        let data1 = ownerProxy.swapOwner(prevOwner: .one, old: .two, new: .three)
        let data2 = ownerProxy.swapOwner(prevOwner: .two, old: .three, new: .one)
        let multiSendProxy = MultiSendContractV1(.zero)
        let encoded = multiSendProxy.multiSend([(.call, .safeAddress, 0, data1),
                                                (.call, .safeAddress, 0, data2)])
        let decoded: [MultiSendTransaction]! = multiSendProxy.decodeMultiSendArguments(from: encoded)
        XCTAssertNotNil(decoded)
        XCTAssertEqual(decoded[0].operation, .call)
        XCTAssertEqual(decoded[0].to, Address(Address.safeAddress.value.lowercased()))
        XCTAssertEqual(decoded[0].value, 0)
        XCTAssertEqual(decoded[0].data, data1)

        XCTAssertEqual(decoded[1].operation, .call)
        XCTAssertEqual(decoded[1].to, Address(Address.safeAddress.value.lowercased()))
        XCTAssertEqual(decoded[1].value, 0)
        XCTAssertEqual(decoded[1].data, data2)
    }

    func test_decode_v2() {
        DomainRegistry.put(service: EncryptionService(), for: EncryptionDomainService.self)
        let ownerProxy = SafeOwnerManagerContractProxy(.safeAddress)
        let data1 = ownerProxy.swapOwner(prevOwner: .one, old: .two, new: .three)
        let data2 = ownerProxy.swapOwner(prevOwner: .two, old: .three, new: .one)
        let multiSendProxy = MultiSendContractV2(.zero)
        let encoded = multiSendProxy.multiSend([(.call, .safeAddress, 0, data1),
                                                (.call, .safeAddress, 0, data2)])
        let decoded: [MultiSendTransaction]! = multiSendProxy.decodeMultiSendArguments(from: encoded)
        XCTAssertNotNil(decoded)
        XCTAssertEqual(decoded[0].operation, .call)
        XCTAssertEqual(decoded[0].to, Address(Address.safeAddress.value.lowercased()))
        XCTAssertEqual(decoded[0].value, 0)
        XCTAssertEqual(decoded[0].data, data1)

        XCTAssertEqual(decoded[1].operation, .call)
        XCTAssertEqual(decoded[1].to, Address(Address.safeAddress.value.lowercased()))
        XCTAssertEqual(decoded[1].value, 0)
        XCTAssertEqual(decoded[1].data, data2)
    }

    func test_whenAddressZero_thenInitsFromMetadata() {
        let metadata = SafeContractMetadata(multiSendContractAddress: .testAccount1,
                                            proxyFactoryAddress: .testAccount1,
                                            proxyCode: Data(),
                                            defaultFallbackHandlerAddress: .testAccount4,
                                            safeFunderAddress: .testAccount1,
                                            masterCopy: [MasterCopyMetadata(address: .testAccount2,
                                                                            version: "1",
                                                                            txTypeHash: Data(),
                                                                            domainSeparatorHash: Data())],
                                            multiSend: [])

        DomainRegistry.put(service: InMemorySafeContractMetadataRepository(metadata: metadata),
                           for: SafeContractMetadataRepository.self)
        DomainRegistry.put(service: EncryptionService(), for: EncryptionDomainService.self)
        let proxy = MultiSendContractProxy()
        XCTAssertEqual(proxy.contract, .testAccount1)
    }

}
