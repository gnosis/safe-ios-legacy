//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
import CommonTestSupport
@testable import SafeUIKit

class QRCodeViewTests: XCTestCase {

    let view = QRCodeView()

    func test_whenPaddingIsSet_thenFrameIsAdjusted() {
        view.bounds = CGRect(x: 0, y: 0, width: 40, height: 40)
        XCTAssertEqual(view.imageView.frame, view.bounds)
        view.padding = 5
        XCTAssertEqual(view.imageView.frame, CGRect(x: 5, y: 5, width: 30, height: 30))
    }

    func test_whenPaddingConflictsWithBounds_thenItDoesNotWork() {
        view.bounds = CGRect(x: 0, y: 0, width: 40, height: 40)
        view.padding = -1
        XCTAssertEqual(view.imageView.frame, view.bounds)
        view.padding = 20
        XCTAssertEqual(view.imageView.frame, view.bounds)
        view.padding = 19
        XCTAssertEqual(view.imageView.frame, CGRect(x: 19, y: 19, width: 2, height: 2))
    }

}
