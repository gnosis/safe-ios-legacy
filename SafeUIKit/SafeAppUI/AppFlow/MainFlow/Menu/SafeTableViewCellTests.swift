//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class SafeTableViewCellTests: XCTestCase {

    let cell = SafeTableViewCell()

    func test_whenSharing_thenCompletionIsCalled() {
        var didShare = false
        cell.onShare = {
            didShare = true
        }
        cell.share(self)
        XCTAssertTrue(didShare)
    }

    func test_whenShowingQRCode_thenCallsCompletion() {
        var didShow = false
        cell.onShowQRCode = {
            didShow = true
        }
        cell.showQRCode(self)
        XCTAssertTrue(didShow)
    }

}
