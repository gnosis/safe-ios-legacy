//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class TransactionDetailsViewControllerTests: XCTestCase {

    func test_canCreate() {
        let controller = TransactionDetailsViewController.create()
        createWindow(controller)
        XCTAssertNotNil(controller)
    }

}
