//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class OnboardingWelcomeViewControllerTests: XCTestCase {

    // swiftlint:disable:next weak_delegate
    let delegate = MockOnboardingWelcomeViewControllerDelegate()
    var vc: OnboardingWelcomeViewController!

    override func setUp() {
        super.setUp()
        delegate.wasCalled = false
        vc = OnboardingWelcomeViewController.create(delegate: delegate)
        vc.loadViewIfNeeded()
    }

    func test_canCreate() {
        XCTAssertNotNil(vc.descriptionLabel)
    }

    func test_whenSetupPasswordActionSent_thenDelegateCalled() {
        vc.setupPassword(self)
        XCTAssertTrue(delegate.wasCalled)
    }

    func test_tracking() {
        XCTAssertTracksAppearance(in: vc, OnboardingTrackingEvent.welcome)
    }

}

class MockOnboardingWelcomeViewControllerDelegate: OnboardingWelcomeViewControllerDelegate {

    var wasCalled = false

    func didStart() {
        wasCalled = true
    }

}
