//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe
import IdentityAccessApplication

class PairWithBrowserExtensionFlowCoordinatorTests: XCTestCase {

    var flowCoordinator: PairWithBrowserExtensionFlowCoordinator!
    var nav = UINavigationController()
    var draftSafe: DraftSafe!
    var completionCalled = false

    override func setUp() {
        super.setUp()
        flowCoordinator = PairWithBrowserExtensionFlowCoordinator(draftSafe: draftSafe) { [unowned self] in
            self.completionCalled = true
        }
        let startVC = flowCoordinator.startViewController(parent: nav)
        nav.pushViewController(startVC, animated: false)
    }

    func test_startViewController_returnsPairWithChromeExtensionVC() {
        XCTAssertTrue(nav.topViewController is PairWithBrowserExtensionViewController)
    }

}
