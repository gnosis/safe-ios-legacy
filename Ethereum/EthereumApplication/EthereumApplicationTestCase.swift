//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import EthereumApplication
import EthereumImplementations
import EthereumDomainModel

class EthereumApplicationTestCase: XCTestCase {

    let ethereumApplicationService = MockEthereumApplicationService()
    let encryptionService = MockEncryptionService()

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: ethereumApplicationService, for: EthereumApplicationService.self)
        DomainRegistry.put(service: encryptionService, for: EncryptionDomainService.self)
    }

}
