//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit

class TransactionConfirmationViewTests: XCTestCase {

    let confirmationView = TransactionConfirmationView()

    func test_canCreate() {
        XCTAssertNotNil(confirmationView)
    }

}
