//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import ReplaceBrowserExtensionUI

class RBEIntroViewControllerStartedStateTests: RBEIntroViewControllerBaseTestCase {

    func test_whenStarted_thenNoLongerLoading() {
        vc.startIndicateLoading()
        vc.disableStart()
        vc.showRetry()
        vc.transition(to: RBEIntroViewController.StartedState())
        XCTAssertNil(vc.navigationItem.titleView)
        XCTAssertEqual(vc.navigationItem.rightBarButtonItems, [vc.startButtonItem])
        XCTAssertTrue(vc.startButtonItem.isEnabled)
    }

    func test_whenStarted_thenNotifiesDelegate() {
        let delegate = TestRBEIntroViewControllerDelegate()
        vc.delegate = delegate
        vc.transition(to: RBEIntroViewController.StartedState())
        XCTAssertTrue(delegate.didCall)
    }

    func test_whenStarted_thenCanRestart() {
        vc.transition(to: RBEIntroViewController.StartedState())
        vc.start()
        XCTAssertTrue(vc.state is RBEIntroViewController.StartingState)
    }

}

class TestRBEIntroViewControllerDelegate: RBEIntroViewControllerDelegate {

    var didCall = false

    func rbeIntroViewControllerDidStart() {
        didCall = true
    }

}
