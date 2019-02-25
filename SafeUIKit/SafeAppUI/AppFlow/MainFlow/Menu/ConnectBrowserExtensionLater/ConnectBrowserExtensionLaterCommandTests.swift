//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import MultisigWalletDomainModel
import MultisigWalletApplication

class ConnectBrowserExtensionLaterCommandTests: XCTestCase {

    let mockReplaceService = MockReplaceBrowserExtensionDomainService()
    let settingsService = WalletSettingsApplicationService()
    let command = ConnectBrowserExtensionLaterCommand()

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: mockReplaceService, for: ReplaceBrowserExtensionDomainService.self)
        ApplicationServiceRegistry.put(service: settingsService, for: WalletSettingsApplicationService.self)
    }

    func test_whenNoBrowserExtension_thenCanConnect() {
        XCTAssertTrue(command.isHidden)
        mockReplaceService.serviceIsAvailable = false
        XCTAssertFalse(command.isHidden)
    }

}

class MockReplaceBrowserExtensionDomainService: ReplaceBrowserExtensionDomainService {

    var serviceIsAvailable = true
    override var isAvailable: Bool {
        return serviceIsAvailable
    }

}
