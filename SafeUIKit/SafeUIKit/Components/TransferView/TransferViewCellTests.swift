//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit

class TransferViewCellTests: XCTestCase {

    func test_canCreate() {
        XCTAssertNotNil(TransferViewCell(style: .default, reuseIdentifier: "cell"))
    }

}
