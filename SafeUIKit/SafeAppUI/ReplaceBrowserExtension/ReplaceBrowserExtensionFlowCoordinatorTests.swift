//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import ReplaceBrowserExtensionUI
import MultisigWalletApplication

class ReplaceBrowserExtensionFlowCoordinatorTests: XCTestCase {

    func test_onEnter_pushesIntro() {
        ApplicationServiceRegistry.put(service: WalletSettingsApplicationService(),
                                       for: WalletSettingsApplicationService.self)
        let nav = UINavigationController()
        let fc = ReplaceBrowserExtensionFlowCoordinator(rootViewController: nav)
        fc.setUp()
        XCTAssertTrue(nav.topViewController is RBEIntroViewController)
    }

}
