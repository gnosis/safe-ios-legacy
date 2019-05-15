//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class ReplaceRecoveryPhraseViewControllerTests: XCTestCase {

    func test_tracking() {
        let controller = ReplaceRecoveryPhraseViewController.create(delegate: nil)
        XCTAssertTracksAppearance(in: controller, ReplaceRecoveryPhraseTrackingEvent.intro)
    }

}
