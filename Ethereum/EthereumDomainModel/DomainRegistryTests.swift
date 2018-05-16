//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import EthereumDomainModel
import EthereumImplementations

class DomainRegistryTests: XCTestCase {

    func test_exists() {
        DomainRegistry.put(service: EncryptionService(), for: EncryptionDomainService.self)
        XCTAssertNotNil(DomainRegistry.encryptionService)
    }

}
