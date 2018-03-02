//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class AppDelegateTests: XCTestCase {

    func test_createWindow() {
        let appDelegate = AppDelegate()
        _ = appDelegate.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)
        XCTAssertNotNil(appDelegate.window)
        XCTAssertNotNil(appDelegate.window?.rootViewController)
        XCTAssertTrue(appDelegate.window?.isKeyWindow ?? false)
    }

}
