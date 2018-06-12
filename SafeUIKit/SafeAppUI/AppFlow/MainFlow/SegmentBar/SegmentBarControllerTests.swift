//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import CommonTestSupport

class SegmentBarControllerTests: XCTestCase {

    var controller: SegmentBarController!
    var segmentA: TestSegmentController!
    var segmentB: TestSegmentController!

    override func setUp() {
        super.setUp()
        controller = SegmentBarController()
        segmentA = TestSegmentController()
        segmentA.segmentItem.title = "segmentA"
        segmentB = TestSegmentController()
        segmentB.segmentItem.title = "segmentB"
        controller.viewControllers = [segmentA, segmentB]
    }

    func test_whenSettingControllers_thenRetainsThem() {
        // casting to UIViewController becuase type UIViewController & SegmentedController is not equatable
        XCTAssertEqual(controller.viewControllers as [UIViewController], [segmentA, segmentB])
    }

    func test_whenSelectingController_thenRetainsSelection() {
        controller.selectedViewController = controller.viewControllers.first!
        XCTAssertEqual(controller.selectedViewController as UIViewController?, segmentA)
    }

    func test_whenViewLoaded_thenLoadsContents() {
        controller.loadViewIfNeeded()
        XCTAssertFalse(controller.view.subviews.isEmpty)
    }

    func test_whenViewLoadedAndControllersUpdated_thenSegmentUpdated() {
        controller.selectedViewController = segmentB
        controller.loadViewIfNeeded()
        controller.viewControllers = [segmentB, segmentA]
        XCTAssertNil(controller.selectedViewController)
        XCTAssertEqual(controller.segmentBar.items, [segmentB.segmentItem, segmentA.segmentItem])
    }

    func test_whenChangingSelection_thenOtherControllerShowsUp() {
        controller.selectedViewController = segmentA
        createWindow(controller)
        controller.selectedViewController = segmentB
        XCTAssertNil(segmentA.view.window)
        XCTAssertNotNil(segmentB.view.window)
    }

    func test_whenSegmentTapped_thenSelectedControllerChanges() {
        controller.selectedViewController = segmentA
        createWindow(controller)
        XCTAssertNil(segmentB.view.window)
        controller.segmentBar.buttons.last?.sendActions(for: .touchUpInside)
        XCTAssertNotNil(segmentB.view.window)
    }

    func test_whenSegmentChangedAndNotSelected_thenResetsSelectedController() {
        controller.selectedViewController = segmentA
        createWindow(controller)
        XCTAssertNotNil(controller.selectedViewController)
        controller.segmentBar.selectedItem = nil
        XCTAssertNotNil(controller.selectedViewController)
        controller.segmentBar.sendActions(for: .valueChanged)
        XCTAssertNil(controller.selectedViewController)
    }

}

class TestSegmentController: UIViewController, SegmentController {
    var segmentItem = SegmentBarItem(title: "testSegment")
}
