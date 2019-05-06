//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit

class FeeCalculationTests: XCTestCase {

    class MyError: Error {}

    func test_api() {
        let view = FeeCalculationView(FeeCalculation().addSection {
            $0.addAssetLine { $0.set(style: .balance).set(name: "Balance").set(value: "- ETH") }
                .addAssetLine { $0.set(name: "Network fee").set(button: "[?]", target: nil, action: nil) }
                .addEmptyLine()
                .addAssetLine { $0.set(name: "Resulting balance").set(value: "- ETH").set(error: MyError()) }
        })
        XCTAssertNotNil(view)
    }
}
