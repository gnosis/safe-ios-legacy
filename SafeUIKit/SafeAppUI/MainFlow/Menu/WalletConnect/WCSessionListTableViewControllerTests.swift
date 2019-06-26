//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class WCSessionListTableViewControllerTests: XCTestCase {

    var controller: WCSessionListTableViewController!

    override func setUp() {
        super.setUp()
        controller = WCSessionListTableViewController()
        controller.viewDidLoad()
    }

    func test_whenNoActiveSessions_thenShowsNoSessionsView() {
        XCTAssertTrue(controller.tableView.backgroundView is EmptyResultsView)
    }

}
