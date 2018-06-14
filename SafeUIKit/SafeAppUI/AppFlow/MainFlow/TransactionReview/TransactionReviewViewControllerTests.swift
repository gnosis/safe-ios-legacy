//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class TransactionReviewViewControllerTests: XCTestCase {

    func test_canCreate() {
        let controller = TransactionReviewViewController.create()
        createWindow(controller)
        XCTAssertNotNil(controller)
    }

}
