//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class HorizontalSeparatorViewTests: XCTestCase {

    func test_whenSizeChanged_thenHeightChanges() {
        let view = HorizontalSeparatorView()
        view.size = 3
        XCTAssertEqual(view.heightConstraint.constant, 3)
    }

}
