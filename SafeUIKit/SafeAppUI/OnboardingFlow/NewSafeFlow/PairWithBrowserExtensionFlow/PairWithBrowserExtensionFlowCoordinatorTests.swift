//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class PairWithBrowserExtensionFlowCoordinatorTests: XCTestCase {

    var flowCoordinator: PairWithBrowserExtensionFlowCoordinator!
    var nav = UINavigationController()

    override func setUp() {
        super.setUp()
        flowCoordinator = PairWithBrowserExtensionFlowCoordinator(address: nil, rootViewController: UINavigationController())
        flowCoordinator.setUp()
    }

    func test_startViewController_returnsPairWithChromeExtensionVC() {
        let topViewController = flowCoordinator.navigationController.topViewController
        XCTAssertTrue(topViewController is PairWithBrowserExtensionViewController)
        let controller = topViewController as! PairWithBrowserExtensionViewController
        XCTAssertTrue(controller.delegate === flowCoordinator)
    }

    func test_didPair_callsCompletion() {
        let testAddress = "test_address"
        flowCoordinator.didPair(testAddress)
        XCTAssertEqual(flowCoordinator.extensionAddress, testAddress)
    }

}
