//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import MultisigWalletApplication

class ConnectBrowserExtensionLaterCommandTests: XCTestCase {

    let connectService = MockConnectExtensionApplicationService()
    let command = ConnectTwoFACommand()

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: connectService, for: ConnectTwoFAApplicationService.self)
    }

    func test_whenNoBrowserExtension_thenCanConnect() {
        XCTAssertFalse(command.isHidden)
        connectService.isAvailableResult = false
        XCTAssertTrue(command.isHidden)
    }

}
