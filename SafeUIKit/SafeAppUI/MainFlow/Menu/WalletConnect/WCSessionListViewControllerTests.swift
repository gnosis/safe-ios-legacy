//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class WCSessionListViewControllerTests: XCTestCase {

    var controller: WCSessionListViewController!

    override func setUp() {
        super.setUp()
        controller = WCSessionListViewController()
        controller.viewDidLoad()
    }

    func test_whenNoActiveSessions_thenShowsNoSessionsView() {
        XCTAssertTrue(controller.tableView.backgroundView is EmptyResultsView)
    }

}
