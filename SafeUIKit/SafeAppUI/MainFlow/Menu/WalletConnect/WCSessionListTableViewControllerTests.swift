//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import CommonTestSupport

class WCSessionListTableViewControllerTests: SafeTestCase {

    var controller: WCSessionListTableViewController!

    override func setUp() {
        super.setUp()
        controller = WCSessionListTableViewController()
        controller.loadViewIfNeeded()
    }

    func test_whenNoActiveSessions_thenShowsNoSessionsView() {
        delay()
        XCTAssertTrue(controller.tableView.backgroundView is EmptyResultsView)
    }

    func test_trackingAppearance() {
        XCTAssertTracksAppearance(in: controller, WCTrackingEvent.sessionList)
    }

    func test_whenOpensCamera_thenTracksScan() {
        XCTAssertTracks { handler in
            controller.scanBarButtonItemWantsToPresentController(UIViewController())
            XCTAssertEqual(handler.screenName(at: 0), WCTrackingEvent.scan.rawValue)
        }
    }

    func test_scanValidatorConverter() {
        XCTAssertNotNil(controller.scanButtonItem.scanValidatedConverter?("wc:some"))
        XCTAssertNil(controller.scanButtonItem.scanValidatedConverter!("some"))
    }

    func test_whenScanningValidURL_thenCallsService() {
        controller.scanBarButtonItemDidScanValidCode("some")
        XCTAssertNotNil(walletConnectService.connectURL)
    }

    func test_whenCreated_thenSubscribesOnEvents() {
        XCTAssertTrue(walletConnectService.didSubscribe)
    }

    func test_whenInitWithURL_thenConnects() {
        controller = WCSessionListTableViewController(connectionURL: URL(string: "wc:123")!)
        controller.loadViewIfNeeded()
        XCTAssertNotNil(walletConnectService.connectURL)
    }

}
