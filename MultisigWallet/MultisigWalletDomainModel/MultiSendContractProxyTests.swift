//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel
import MultisigWalletImplementations

class MultiSendContractProxyTests: XCTestCase {

    func test_decode() {
        DomainRegistry.put(service: EncryptionService(), for: EncryptionDomainService.self)
        let ownerProxy = SafeOwnerManagerContractProxy(.safeAddress)
        let data1 = ownerProxy.swapOwner(prevOwner: .one, old: .two, new: .three)
        let data2 = ownerProxy.swapOwner(prevOwner: .two, old: .three, new: .one)
        let multiSendProxy = MultiSendContractProxy(.zero)
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

}
