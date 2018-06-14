//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class TransactionDetailsViewControllerTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func test_whenCondition_thenResult() {
        let controller = TransactionDetailsViewController.create()
        createWindow(controller)
    }

}
