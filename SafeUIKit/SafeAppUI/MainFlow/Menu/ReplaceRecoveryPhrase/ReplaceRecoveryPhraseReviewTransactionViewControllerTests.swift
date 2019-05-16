//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class ReplaceRecoveryPhraseReviewTransactionViewControllerTests: ReviewTransactionViewControllerBaseTestCase {

    var controller: ReplaceRecoveryPhraseReviewTransactionViewController!

    override func setUp() {
        super.setUp()
        controller = ReplaceRecoveryPhraseReviewTransactionViewController(transactionID: "Some", delegate: delegate)
        controller.loadViewIfNeeded()
    }

    func test_trackAppearance() {
        XCTAssertTracksAppearance(in: controller, ReplaceRecoveryPhraseTrackingEvent.review)
    }

    func test_whenSubmitted_thenTracks() {
        XCTAssertTracks(ReplaceRecoveryPhraseTrackingEvent.success) {
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
