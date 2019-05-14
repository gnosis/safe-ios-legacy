//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class GuidelinesViewControllerTests: XCTestCase {

    let controller = GuidelinesViewController.create()

    func test_whenScreenEventNotSet_thenTracksDefault() {
        XCTAssertTracksAppearance(in: controller, OnboardingTrackingEvent.recoveryIntro)
    }

    func test_whenScreenEventSet_thenTracksIt() {
        controller.screenTrackingEvent = TestScreenTrackingEvent.view
        XCTAssertTracksAppearance(in: controller, TestScreenTrackingEvent.view)
    }

}
