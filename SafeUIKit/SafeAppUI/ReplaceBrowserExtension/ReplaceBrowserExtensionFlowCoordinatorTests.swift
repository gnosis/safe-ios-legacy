//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import ReplaceBrowserExtensionUI
import MultisigWalletApplication
import ReplaceBrowserExtensionFacade

class ReplaceBrowserExtensionFlowCoordinatorTests: XCTestCase {

    let nav = UINavigationController()
    var fc: ReplaceBrowserExtensionFlowCoordinator!
    let mockSettingsService = MockWalletSettingsApplicationService()

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: WalletSettingsApplicationService(),
                                       for: WalletSettingsApplicationService.self)
        fc = ReplaceBrowserExtensionFlowCoordinator(rootViewController: nav)
        fc.setUp()
    }

    func test_onEnter_pushesIntro() {
        XCTAssertTrue(nav.topViewController is RBEIntroViewController)
    }

    func test_whenIntroDidStart_thenTakesTransactionID() {
        fc.introVC!.transactionID = "Some"
        fc.rbeIntroViewControllerDidStart()
        XCTAssertEqual(fc.transactionID, "Some")
    }

    func test_whenScannedCode_thenConnects() throws {
        ApplicationServiceRegistry.put(service: mockSettingsService, for: WalletSettingsApplicationService.self)
        fc.introVC!.transactionID = "Some"
        fc.rbeIntroViewControllerDidStart()
        let vc = PairWithBrowserExtensionViewController.create(delegate: nil)
        try fc.pairWithBrowserExtensionViewController(vc, didScanAddress: "Address", code: "Code")
        XCTAssertTrue(mockSettingsService.didCallConnect)
    }

}

class MockWalletSettingsApplicationService: WalletSettingsApplicationService {

    var didCallConnect = false

    override func connect(transaction: RBETransactionID, code: String) throws {
        didCallConnect = true
    }

}
