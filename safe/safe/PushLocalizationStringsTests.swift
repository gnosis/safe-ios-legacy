//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe

class PushLocalizationStringsTests: XCTestCase {

    func test_values() {
        assertAlertNotNil(from: ["type": "sendTransaction"])
        assertAlertNotNil(from: ["type": "confirmTransaction"])
        assertAlertNotNil(from: ["type": "rejectTransaction"])
        XCTAssertNil(PushLocalizationStrings.alertContent(from: ["type": "UNKNOWN"]))
        XCTAssertNil(PushLocalizationStrings.alertContent(from: ["key": "value"]))
    }

    private func assertAlertNotNil(from userInfo: [AnyHashable: Any], line: UInt = #line) {
        let alert = PushLocalizationStrings.alertContent(from: userInfo)
        XCTAssertNotNil(alert?.title)
        XCTAssertNotNil(alert?.body)
    }

}
