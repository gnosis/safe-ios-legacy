//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class RecoverSafeFlowCoordinatorTests: XCTestCase {

    func test_tracking() {
        let coordinator = RecoverSafeFlowCoordinator()

        let introEvent = coordinator.introViewController().screenTrackingEvent as? RecoverSafeTrackingEvent
        XCTAssertEqual(introEvent, .intro)

        let twoFAScreenEvent = coordinator.newPairController().screenTrackingEvent as? RecoverSafeTrackingEvent
        XCTAssertEqual(twoFAScreenEvent, .twoFA)

        let twoFAScanEvent = coordinator.newPairController().scanTrackingEvent as? RecoverSafeTrackingEvent
        XCTAssertEqual(twoFAScanEvent, .twoFAScan)

        let phraseEvent = coordinator.recoveryPhraseViewController().screenTrackingEvent as? RecoverSafeTrackingEvent
        XCTAssertEqual(phraseEvent, .enterSeed)
    }

}
