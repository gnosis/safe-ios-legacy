//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import ReplaceBrowserExtensionUI

class RBEIntroViewControllerStartingStateTests: RBEIntroViewControllerBaseTestCase {

    func test_whenStarting_thenCorrectUI() {
        vc.navigationItem.titleView = nil
        vc.navigationItem.rightBarButtonItems = [vc.retryButtonItem]
        vc.transition(to: RBEIntroViewController.StartingState())
        XCTAssertFalse(vc.startButtonItem.isEnabled)
        XCTAssertTrue(vc.navigationItem.titleView is LoadingTitleView)
        XCTAssertEqual(vc.navigationItem.rightBarButtonItems, [vc.startButtonItem])
    }

}
