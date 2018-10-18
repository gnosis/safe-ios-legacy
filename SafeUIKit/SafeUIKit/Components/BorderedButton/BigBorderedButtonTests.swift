//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit

class BigBorderedButtonTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func test_button() {
        let button = BigBorderedButton()
        XCTAssertEqual(button.titleColor(for: .normal), .white)
        XCTAssertEqual(button.titleLabel?.font, UIFont.systemFont(ofSize: 17))
        XCTAssertEqual(button.layer.borderWidth, 1)
        XCTAssertEqual(button.layer.borderColor, UIColor.white.cgColor)
        XCTAssertEqual(button.layer.cornerRadius, 6)
    }

}
