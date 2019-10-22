//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class GetInTouchTableViewControllerTests: XCTestCase {

    var controller: MockGetInTouchTableViewController!

    override func setUp() {
        super.setUp()
        controller = MockGetInTouchTableViewController()
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
        XCTAssertFalse(controller.didOpenTelegram)
        selectCell(row: 0, section: 0)
        XCTAssertTrue(controller.didOpenTelegram)
    }

    func test_whenSelectingMail_thenCallsDelegate() {
        XCTAssertFalse(controller.didOpenMail)
        selectCell(row: 1, section: 0)
        XCTAssertTrue(controller.didOpenMail)
    }

    func test_whenSelectingGitter_thenCallsDelegate() {
        XCTAssertFalse(controller.didOpenGitter)
        selectCell(row: 2, section: 0)
        XCTAssertTrue(controller.didOpenGitter)
    }

    private func selectCell(row: Int, section: Int) {
        controller.tableView(controller.tableView, didSelectRowAt: IndexPath(row: row, section: section))
    }

}

class MockGetInTouchTableViewController: GetInTouchTableViewController {

    var didOpenTelegram = false
    override func openTelegram() {
        didOpenTelegram = true
    }

    var didOpenMail = false
    override func openMail() {
        didOpenMail = true
    }

    var didOpenGitter = false
    override func openGitter() {
        didOpenGitter = true
    }

}
