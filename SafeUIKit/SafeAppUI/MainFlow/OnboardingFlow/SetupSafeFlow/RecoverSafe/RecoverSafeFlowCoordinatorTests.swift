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

        let twoFAScreenEvent = coordinator.newPairController().screenTrackingEvent as? TwoFATrackingEvent
        XCTAssertEqual(twoFAScreenEvent, .connectAuthenticator)

        let twoFAScanEvent = coordinator.newPairController().scanTrackingEvent as? TwoFATrackingEvent
        XCTAssertEqual(twoFAScanEvent, .connectAuthenticatorScan)

        let phraseEvent = coordinator.recoveryPhraseViewController().screenTrackingEvent as? RecoverSafeTrackingEvent
        XCTAssertEqual(phraseEvent, .enterSeed)
    }

}
