//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest

class safeUIKitDemoUITests: XCTestCase {

    let app = XCUIApplication()

    var textInput: XCUIElement {
        return app.otherElements["testTextInput"]
    }

    var textField: XCUIElement {
        return textInput.textFields.firstMatch
    }
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launch()
        app.staticTexts["TextInput"].tap()
    }

    func test_textInput() {
        // Initial state, no rules
        waitUntil(textField.exists)
        XCTAssertFalse(textInput.staticTexts["Success Rule"].exists)
        XCTAssertFalse(textInput.staticTexts["Failing Rule"].exists)
        XCTAssertFalse(textInput.staticTexts["Empty Rule"].exists)

        // Add rules
        app.buttons["Add success rule"].tap()
        app.buttons["Add failing rule"].tap()
        app.buttons["Add empty rule"].tap()
        XCTAssertEqual(labelValue("Success Rule"), "Inactive Success Rule")
        XCTAssertEqual(labelValue("Failing Rule"), "Inactive Failing Rule")
        XCTAssertEqual(labelValue("Empty Rule"), "Inactive Empty Rule")

        // Type some text
        textField.tap()
        textField.typeText("qweQWE")
        XCTAssertEqual(labelValue("Success Rule"), "Success Success Rule")
        XCTAssertEqual(labelValue("Failing Rule"), "Error Failing Rule")
        XCTAssertEqual(labelValue("Empty Rule"), "Inactive Empty Rule")

        // Clear text
        app.buttons["Clear text"].tap()
        XCTAssertEqual(labelValue("Success Rule"), "Inactive Success Rule")
        XCTAssertEqual(labelValue("Failing Rule"), "Inactive Failing Rule")
        XCTAssertEqual(labelValue("Empty Rule"), "Inactive Empty Rule")
    }

    private func labelValue(_ name: String) -> String? {
        return textInput.staticTexts[name].value as? String
    }

}
