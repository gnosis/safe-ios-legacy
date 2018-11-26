//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit

class ProgressViewTests: XCTestCase {

    let view = ProgressView()

    func test_whenDataChanges_thenViewChanges() {
        view.progress = 0.6; view.isError = false; view.isIndeterminate = false
        XCTAssertEqual(view.state, .progress(0.6))

        view.progress = 0.4; view.isError = true; view.isIndeterminate = false
        XCTAssertEqual(view.state, .error)

        view.progress = 0.4; view.isError = true; view.isIndeterminate = true
        XCTAssertEqual(view.state, .error)

        view.progress = 0.5; view.isError = false; view.isIndeterminate = true
        XCTAssertEqual(view.state, .indeterminate)
    }

}
