//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class ReviewRecoveryTransactionViewControllerTests: XCTestCase {

    func test_tracking() {
        let controller = ReviewRecoveryTransactionViewController.create(delegate: nil)
        XCTAssertTracksAppearance(in: controller, RecoverSafeTrackingEvent.review)
    }

}
