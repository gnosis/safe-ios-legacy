//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit

class TransactionFeeCellTests: XCTestCase {

    func test_canCreate() {
        XCTAssertNotNil(TransactionFeeCell(style: .default, reuseIdentifier: "cell"))
    }

}
