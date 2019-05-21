//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import CommonTestSupport
import MultisigWalletApplication

class MainViewControllerSegmentTests: SafeTestCase {

    var controller: MainViewController!
    var segmentA: UIViewController & SegmentController {
        return controller.viewControllers[0]
    }
    var segmentB: UIViewController & SegmentController {
        return controller.viewControllers[1]
    }
    // swiftlint:disable weak_delegate
    var delegate: MockMainViewControllerDelegate!

    override func setUp() {
        super.setUp()
        walletService.expect_grouppedTransactions(result: [.group(count: 1)])
        delegate = MockMainViewControllerDelegate()
        controller = MainViewController.create(delegate: delegate)
        createWindow(controller)
    }

    func test_whenSelectingController_thenRetainsSelection() {
        controller.selectedViewController = controller.viewControllers.first!
        XCTAssertEqual(controller.selectedViewController as UIViewController?, segmentA)
    }

    func test_whenViewLoaded_thenLoadsContents() {
        XCTAssertFalse(controller.view.subviews.isEmpty)
    }

    func test_whenViewLoadedAndControllersUpdated_thenSegmentUpdated() {
        controller.selectedViewController = segmentB
        let expectedSegments = [segmentB, segmentA]
        controller.viewControllers = expectedSegments
        XCTAssertNil(controller.selectedViewController)
        XCTAssertEqual(controller.segmentBar.items, [expectedSegments[0].segmentItem, expectedSegments[1].segmentItem])
    }

    func test_whenChangingSelection_thenOtherControllerShowsUp() {

        controller.selectedViewController = segmentA
        controller.selectedViewController = segmentB
        XCTAssertNil(segmentA.view.window)
        XCTAssertNotNil(segmentB.view.window)
    }

    func test_whenSegmentTapped_thenSelectedControllerChanges() {
        controller.selectedViewController = segmentA
        XCTAssertNil(segmentB.view.window)
        controller.segmentBar.buttons.last?.sendActions(for: .touchUpInside)
        XCTAssertNotNil(segmentB.view.window)
    }

    func test_whenSegmentChangedAndNotSelected_thenResetsSelectedController() {
        controller.selectedViewController = segmentA
        XCTAssertNotNil(controller.selectedViewController)
        controller.segmentBar.selectedItem = nil
        XCTAssertNotNil(controller.selectedViewController)
        controller.segmentBar.sendActions(for: .valueChanged)
        XCTAssertNil(controller.selectedViewController)
    }

}
