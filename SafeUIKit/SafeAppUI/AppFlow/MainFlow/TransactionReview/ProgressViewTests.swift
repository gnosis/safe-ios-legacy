//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class ProgressViewTests: XCTestCase {

    let view = ProgressView()

    func test_whenDataChanges_thenViewChanges() {
        view.progress = 0.6; view.isError = false; view.isIndeterminate = false
        assert(progress: 0.6, error: false, indeterminate: false)

        view.progress = 0.4; view.isError = true; view.isIndeterminate = false
        assert(progress: 0, error: true, indeterminate: false)

        view.progress = 0.4; view.isError = true; view.isIndeterminate = true
        assert(progress: 0, error: true, indeterminate: false)

        view.progress = 0.5; view.isError = false; view.isIndeterminate = true
        assert(progress: 0, error: false, indeterminate: true)
    }

}

extension ProgressViewTests {

    private func assert(progress: Double, error: Bool, indeterminate: Bool, line: UInt = #line) {
        XCTAssertEqual(view.state.doubleValue, progress, line: line)
        XCTAssertEqual(view.state.isError, error, line: line)
        XCTAssertEqual(view.state.isIndeterminate, indeterminate, line: line)
    }

}
