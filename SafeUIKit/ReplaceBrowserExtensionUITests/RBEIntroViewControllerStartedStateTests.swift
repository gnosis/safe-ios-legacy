//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import ReplaceBrowserExtensionUI

class RBEIntroViewControllerStartedStateTests: RBEIntroViewControllerBaseTestCase {

    func test_whenStarted_thenNoLongerLoading() {
        vc.startIndicateLoading()
        vc.enableStart()
        vc.showRetry()
        vc.transition(to: RBEIntroViewController.StartedState())
        XCTAssertNil(vc.navigationItem.titleView)
        XCTAssertEqual(vc.navigationItem.rightBarButtonItems, [vc.startButtonItem])
        XCTAssertFalse(vc.startButtonItem.isEnabled)
    }

}
