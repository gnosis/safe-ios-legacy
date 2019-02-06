//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import ReplaceBrowserExtensionUI

class ReplaceBrowserExtensionFlowCoordinatorTests: XCTestCase {

    func test_onEnter_pushesIntro() {
        let nav = UINavigationController()
        let fc = ReplaceBrowserExtensionFlowCoordinator(rootViewController: nav)
        fc.setUp()
        XCTAssertTrue(nav.topViewController is RBEIntroViewController)
    }

}
