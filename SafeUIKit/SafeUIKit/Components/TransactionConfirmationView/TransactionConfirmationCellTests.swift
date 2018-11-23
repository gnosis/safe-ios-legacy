//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit

class TransactionConfirmationCellTests: XCTestCase {

    func test_canCreate() {
        XCTAssertNotNil(TransactionConfirmationCell(style: .default, reuseIdentifier: "cell"))
    }

}
