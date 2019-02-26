//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import ReplaceBrowserExtensionFacade

class RBEIntroViewControllerErrorStateTests: RBEIntroViewControllerBaseTestCase {

    func test_whenError_thenShowsAlert() {
        let vc = TestableRBEIntroViewController.createTestable()
        vc.startIndicateLoading()
        vc.disableStart()
        vc.showRetry()
        vc.transition(to: RBEIntroViewController.ErrorState(error: FeeCalculationError.insufficientBalance))
        XCTAssertTrue(vc.spy_presentedViewController is UIAlertController)
        XCTAssertNil(vc.navigationItem.titleView)
        XCTAssertEqual(vc.navigationItem.rightBarButtonItems, [vc.startButtonItem])
        XCTAssertTrue(vc.startButtonItem.isEnabled)
    }

}
