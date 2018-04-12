//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe

class SafeUIKitExtensionsTests: XCTestCase {

    func test_rootViewController() {
        XCTAssertTrue(UIApplication.rootViewController === UIApplication.shared.keyWindow?.rootViewController)
        let vc = UIViewController()
        UIApplication.rootViewController = vc
        XCTAssertTrue(UIApplication.shared.keyWindow?.rootViewController === vc)
    }

}
