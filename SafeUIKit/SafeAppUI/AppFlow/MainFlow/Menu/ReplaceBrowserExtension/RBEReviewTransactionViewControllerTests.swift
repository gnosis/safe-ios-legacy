//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class RBEReviewTransactionViewControllerTests: ReviewTransactionViewControllerBaseTestCase {

    var controller: RBEReviewTransactionViewController!

    override func setUp() {
        super.setUp()
        controller = RBEReviewTransactionViewController(transactionID: "Some", delegate: delegate)
        controller.loadViewIfNeeded()
    }

    func test_trackAppearance() {
        controller.screenTrackingEvent = TestScreenTrackingEvent.view
        XCTAssertTracksAppearance(in: controller, TestScreenTrackingEvent.view)
    }

    func test_whenSubmitted_thenTracks() {
        controller.successTrackingEvent = TestScreenTrackingEvent.view
        XCTAssertTracks(TestScreenTrackingEvent.view) {
            controller.didSubmit()
        }
    }

    func test_whenOtherEvents_thenDoesNotTrack() {
        XCTAssertTracks { handler in
            controller.didReject()
            controller.didConfirm()
            XCTAssertTrue(handler.events.isEmpty, "Expected 0 events, got: \(handler.events)")
        }
    }

}
