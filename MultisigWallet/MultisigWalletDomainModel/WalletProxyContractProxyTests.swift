//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel
import MultisigWalletImplementations

class WalletProxyContractProxyTests: EthereumContractProxyBaseTests {

    let proxy = WalletProxyContractProxy(Address.testAccount1)

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: EncryptionService(), for: EncryptionDomainService.self)
    }

    func test_changeMasterCopy() {
        let masterCopy = Address.testAccount2
        let data = proxy.changeMasterCopy(masterCopy)
        let decodedAddress = proxy.decodeChangeMasterCopyArguments(from: data)
        XCTAssertEqual(decodedAddress?.value.lowercased(), masterCopy.value.lowercased())
    }

}
