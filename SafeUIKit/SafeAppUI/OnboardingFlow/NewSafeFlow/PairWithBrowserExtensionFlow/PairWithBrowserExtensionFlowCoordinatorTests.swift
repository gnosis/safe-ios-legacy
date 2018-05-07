//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class PairWithBrowserExtensionFlowCoordinatorTests: XCTestCase {

    var flowCoordinator: PairWithBrowserExtensionFlowCoordinator!
    var nav = UINavigationController()
    var extensionAddressFromCompletion = ""

    override func setUp() {
        super.setUp()
        flowCoordinator = PairWithBrowserExtensionFlowCoordinator(address: nil) {
            [unowned self] extensionAddress in
            self.extensionAddressFromCompletion = extensionAddress
        }
        let startVC = flowCoordinator.startViewController(parent: nav)
        nav.pushViewController(startVC, animated: false)
    }

    func test_startViewController_returnsPairWithChromeExtensionVC() {
        XCTAssertTrue(nav.topViewController is PairWithBrowserExtensionViewController)
        let controller = nav.topViewController as! PairWithBrowserExtensionViewController
        XCTAssertTrue(controller.delegate === flowCoordinator)
    }

    func test_didPair_callsCompletion() {
        let testAddress = "test_address"
        flowCoordinator.didPair(testAddress)
        XCTAssertEqual(extensionAddressFromCompletion, testAddress)
    }

}
