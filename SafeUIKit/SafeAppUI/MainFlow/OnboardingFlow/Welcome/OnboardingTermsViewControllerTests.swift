//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class OnboardingTermsViewControllerTests: XCTestCase {

    let controller = OnboardingTermsViewController.create()

    func test_whenTappingButtons_thenCallsDelegate() {
        let delegate = OnboardingTermsViewControllerDelegate()
        controller.delegate = delegate
        createWindow(controller)
        [controller.termsOfUseButton, controller.privacyPolicyButton, controller.disagreeButton,
         controller.agreeButton].forEach { $0?.sendActions(for: .touchUpInside) }
        XCTAssertTrue(delegate.didOpenTermsOfUse, "terms")
        XCTAssertTrue(delegate.didOpenPrivacyPolicy, "privacy")
        XCTAssertTrue(delegate.didCallDisagree, "disagree")
        XCTAssertTrue(delegate.didCallAgree, "agree")
    }

    func test_tracking() {
        XCTAssertTracksAppearance(in: controller, OnboardingTrackingEvent.terms)
    }

}

class TestOnboardingTermsViewControllerDelegate: OnboardingTermsViewControllerDelegate {

    var didOpenTermsOfUse = false
    var didOpenPrivacyPolicy = false
    var didCallDisagree = false
    var didCallAgree = false

    func wantsToOpenTermsOfUse() {
        didOpenTermsOfUse = true
    }

    func wantsToOpenPrivacyPolicy() {
        didOpenPrivacyPolicy = true
    }

    func didDisagree() {
        didCallDisagree = true
    }

    func didAgree() {
        didCallAgree = true
    }

}
