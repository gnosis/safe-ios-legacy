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

class TestableRBEIntroViewController: RBEIntroViewController {

    var spy_presentedViewController: UIViewController?

    override func present(_ viewControllerToPresent: UIViewController,
                          animated flag: Bool,
                          completion: (() -> Void)? = nil) {
        spy_presentedViewController = viewControllerToPresent
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }

    static func createTestable() -> TestableRBEIntroViewController {
        return TestableRBEIntroViewController(nibName: "\(RBEIntroViewController.self)", bundle: Bundle(for: RBEIntroViewController.self))
    }

}
