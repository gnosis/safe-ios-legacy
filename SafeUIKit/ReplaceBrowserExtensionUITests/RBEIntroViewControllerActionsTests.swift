//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import ReplaceBrowserExtensionUI
import UIKit

class RBEIntroViewControllerActionsTests: RBEIntroViewControllerBaseTestCase {

    func test_whenTappingBackButton_thenReceivesBackAction() {
        let vc = TestableRBEIntroViewController.createTestable()
        XCTAssertNotNil(vc.backButtonItem.action)
        guard let action = vc.backButtonItem.action, let target = vc.backButtonItem.target else { return }
        UIApplication.shared.test_sendAction(action, to: target, from: vc.backButtonItem)
        XCTAssertTrue(vc.spy_back_invoked)
    }

}

extension UIApplication {

    func test_sendAction(_ action: Selector, to target: AnyObject, from sender: Any?) {
            target.performSelector(onMainThread: action, with: sender, waitUntilDone: true)
    }

}
