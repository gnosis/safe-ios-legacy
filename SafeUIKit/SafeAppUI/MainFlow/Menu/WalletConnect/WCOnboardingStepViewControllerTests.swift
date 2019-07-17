//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import Common

class WCOnboardingStepViewControllerTests: XCTestCase {

    var testContent = WCOnboardingStepInfo.testContent
    var vc: WCOnboardingStepViewController!

    override func setUp() {
        super.setUp()
        vc = WCOnboardingStepViewController.create(content: testContent)
    }

    func test_whenAppears_thenTracksEvent() {
        XCTAssertTracksAppearance(in: vc, testContent.trackingEvent as! ScreenTrackingEvent)
    }

    func test_whenUpdated_thenSetsContent() {
        vc.loadViewIfNeeded()
        vc.update(content: testContent)
        XCTAssertEqual(vc.imageView.image, testContent.image)
        XCTAssertEqual(vc.titleLabel.text, testContent.title)
        XCTAssertEqual(vc.descriptionLabel.text, testContent.description)
    }

    func test_whenViewNotLoaded_thenJustUpdatesContent() {
        testContent.title = "NewTitle"
        vc.update(content: testContent)
        XCTAssertEqual(vc.content?.title, "NewTitle")
    }

}

extension WCOnboardingStepInfo {

    // swiftlint:disable trailing_closure
    static let testContent = WCOnboardingStepInfo(image: UIImage(),
                                                  title: "TestTitle",
                                                  description: "Test Description",
                                                  actionTitle: "Test Action",
                                                  trackingEvent: TestScreenTrackingEvent.view,
                                                  action: {})

}
