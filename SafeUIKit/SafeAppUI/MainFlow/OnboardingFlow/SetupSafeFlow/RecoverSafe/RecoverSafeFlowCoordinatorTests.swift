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

        let pairVC = AuthenticatorViewController.create(delegate: TestAuthenticatorViewControllerDelegate())
        let twoFAScreenEvent = pairVC.screenTrackingEvent as? TwoFATrackingEvent
        XCTAssertEqual(twoFAScreenEvent, .connectAuthenticator)

        let twoFAScanEvent = pairVC.scanTrackingEvent as? TwoFATrackingEvent
        XCTAssertEqual(twoFAScanEvent, .connectAuthenticatorScan)

        let phraseEvent = coordinator.recoveryPhraseViewController().screenTrackingEvent as? RecoverSafeTrackingEvent
        XCTAssertEqual(phraseEvent, .enterSeed)
    }

}
