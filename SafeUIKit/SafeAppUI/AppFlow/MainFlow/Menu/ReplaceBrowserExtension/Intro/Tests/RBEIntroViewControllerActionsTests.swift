//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import UIKit

class RBEIntroViewControllerActionsTests: RBEIntroViewControllerBaseTestCase {

    func test_whenTapsButtonItems_thenReceivesActions() {
        do_test_buttonItem(itemKeyPath: \.backButtonItem, spyKeyPath: \.spy_back_invoked)
        do_test_buttonItem(itemKeyPath: \.startButtonItem, spyKeyPath: \.spy_start_invoked)
        do_test_buttonItem(itemKeyPath: \.retryButtonItem, spyKeyPath: \.spy_retry_invoked)
    }

    func do_test_buttonItem(itemKeyPath: KeyPath<TestableRBEIntroViewController, UIBarButtonItem>,
                            spyKeyPath: KeyPath<TestableRBEIntroViewController, Bool>,
                            file: StaticString = #file,
                            line: UInt = #line) {
        let vc = TestableRBEIntroViewController.createTestable()
        let item = vc[keyPath: itemKeyPath]
        XCTAssertNotNil(item.action, "Item action is not set", file: file, line: line)
        XCTAssertNotNil(item.target, "Item target is not set", file: file, line: line)
        guard let action = item.action, let target = item.target else { return }
        UIApplication.shared.test_sendAction(action, to: target, from: item)
        XCTAssertTrue(vc[keyPath: spyKeyPath], "Item's action was not invoked", file: file, line: line)
    }

    func test_tracking() {
        vc.screenTrackingEvent = TestScreenTrackingEvent.view
        XCTAssertTracksAppearance(in: vc, TestScreenTrackingEvent.view)
    }

}

extension UIApplication {

    func test_sendAction(_ action: Selector, to target: AnyObject, from sender: Any?) {
            target.performSelector(onMainThread: action, with: sender, waitUntilDone: true)
    }

}
