//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class RecoveryInProgressViewControllerTests: XCTestCase {

    func test_tracking() {
        let controller = RecoveryInProgressViewController.create(delegate: nil)
        controller.isAnimatingProgress = true // to disable animation on viewDidAppear in this test.
        XCTAssertTracksAppearance(in: controller, RecoverSafeTrackingEvent.feePaid)
    }

}
