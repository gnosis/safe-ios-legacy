//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import CommonTestSupport

class WCSessionListTableViewControllerTests: XCTestCase {

    var controller: WCSessionListTableViewController!

    override func setUp() {
        super.setUp()
        controller = WCSessionListTableViewController()
        controller.viewDidLoad()
    }

    func test_whenNoActiveSessions_thenShowsNoSessionsView() {
        // TODO: remove when services are ready
        controller.sessions = []
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

}
