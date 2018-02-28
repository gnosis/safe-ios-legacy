//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest

class safeUIKitDemoUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
        XCUIApplication().staticTexts["TextInput"].tap()
    }

    func test_textInputExists() {
        waitUntil(XCUIApplication().textFields["testTextInput"], is: .exists)
    }
    
}

