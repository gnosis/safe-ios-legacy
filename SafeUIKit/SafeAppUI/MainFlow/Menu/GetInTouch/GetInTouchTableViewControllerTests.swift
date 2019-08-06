//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class GetInTouchTableViewControllerTests: XCTestCase {

    var controller: GetInTouchTableViewController!
    // swiftlint:disable:next weak_delegate
    let delegate = MockGetInTouchTableViewControllerDelegate()

    override func setUp() {
        super.setUp()
        controller = GetInTouchTableViewController(delegate: delegate)
        controller.viewDidLoad()
    }

    func test_whenCreated_thenConfigured() {
        XCTAssertEqual(controller.tableView(controller.tableView, numberOfRowsInSection: 0), 3)
    }

    func test_tracking() {
        XCTAssertTracksAppearance(in: controller, MenuTrackingEvent.getInTouch)
    }

    func test_whenSelectingCell_thenDeselectsIt() {
        selectCell(row: 0, section: 0)
        XCTAssertNil(controller.tableView.indexPathForSelectedRow)
    }

    func test_whenSelectingTelegram_thenCallsDelegate() {
        XCTAssertFalse(delegate.didOpenTelegram)
        selectCell(row: 0, section: 0)
        XCTAssertTrue(delegate.didOpenTelegram)
    }

    func test_whenSelectingMail_thenCallsDelegate() {
        XCTAssertFalse(delegate.didOpenMail)
        selectCell(row: 1, section: 0)
        XCTAssertTrue(delegate.didOpenMail)
    }

    func test_whenSelectingGitter_thenCallsDelegate() {
        XCTAssertFalse(delegate.didOpenGitter)
        selectCell(row: 2, section: 0)
        XCTAssertTrue(delegate.didOpenGitter)
    }

    private func selectCell(row: Int, section: Int) {
        controller.tableView(controller.tableView, didSelectRowAt: IndexPath(row: row, section: section))
    }

}

class MockGetInTouchTableViewControllerDelegate: GetInTouchTableViewControllerDelegate {

    var didOpenTelegram = false
    func openTelegram() {
        didOpenTelegram = true
    }

    var didOpenMail = false
    func openMail() {
        didOpenMail = true
    }

    var didOpenGitter = false
    func openGitter() {
        didOpenGitter = true
    }

}
