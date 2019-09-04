//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class OnboardingToolbarTests: XCTestCase {

    let toolbar = OnboardingToolbar()

    func test_create() {
        XCTAssertNotNil(toolbar.pageControl)
        XCTAssertNotNil(toolbar.actionButtonItem)
    }

    func test_action() {
        let exp = expectation(description: "Tap")
        toolbar.action = {
            exp.fulfill()
        }
        toolbar.actionButtonItem.sendAction()

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func test_changeTitle() {
        toolbar.setActionTitle("MyTitle")
        XCTAssertEqual(toolbar.actionButtonItem.title, "MyTitle")
    }

}

extension UIBarButtonItem {

    func sendAction() {
        if let target = target, let action = action {
            target.performSelector(onMainThread: action, with: nil, waitUntilDone: false)
        }
    }

}
