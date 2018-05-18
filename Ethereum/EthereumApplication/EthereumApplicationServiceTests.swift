//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import EthereumApplication

class EthereumApplicationServiceTests: EthereumApplicationTestCase {

    let applicationService = EthereumApplicationService()

    func test_address_returnsAddressFromEncryptionService() {
        encryptionService.extensionAddress = "some address"
        XCTAssertEqual(applicationService.address(browserExtensionCode: "any code"),
                       encryptionService.address(browserExtensionCode: "any code"))
    }

}
