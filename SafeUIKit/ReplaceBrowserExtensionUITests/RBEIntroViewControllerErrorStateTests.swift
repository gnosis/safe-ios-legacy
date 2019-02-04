//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import ReplaceBrowserExtensionUI

class RBEIntroViewControllerErrorStateTests: RBEIntroViewControllerBaseTestCase {

    func test_whenError_thenShowsAlert() {
        let vc = TestableRBEIntroViewController.createTestable()
        vc.startIndicateLoading()
        vc.disableRetry()
        vc.transition(to: RBEIntroViewController.ErrorState(error: FeeCalculationError.insufficientBalance))
        XCTAssertTrue(vc.spy_presentedViewController is UIAlertController)
        XCTAssertNil(vc.navigationItem.titleView)
        XCTAssertEqual(vc.navigationItem.rightBarButtonItems, [vc.retryButtonItem])
        XCTAssertTrue(vc.retryButtonItem.isEnabled)
    }

}
