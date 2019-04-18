//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
import CommonTestSupport

class SafeUIKitDemoUITests: XCTestCase {

    let app = XCUIApplication()

    struct Status {
        static let inactive = "inactive"
        static let error = "error"
        static let success = "success"
    }

    var textInput: XCUIElement {
        return app.otherElements["testVerifiableInput"]
    }

    var textField: XCUIElement {
        return textInput.textFields.firstMatch
    }

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launch()
        app.staticTexts["VerifiableInput"].tap()
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
        XCTAssertEqual(labelValue("Success Rule"), "\(Status.inactive) Success Rule")
        XCTAssertEqual(labelValue("Failing Rule"), "\(Status.inactive) Failing Rule")
        XCTAssertEqual(labelValue("Empty Rule"), "\(Status.inactive) Empty Rule")

        // Type some text
        textField.tap()
        textField.typeText("qweQWE")
        XCTAssertEqual(labelValue("Success Rule"), "\(Status.success) Success Rule")
        XCTAssertEqual(labelValue("Failing Rule"), "\(Status.error) Failing Rule")
        XCTAssertEqual(labelValue("Empty Rule"), "\(Status.inactive) Empty Rule")

        // Clear text
        app.buttons["Clear text"].tap()
        XCTAssertEqual(labelValue("Success Rule"), "\(Status.inactive) Success Rule")
        XCTAssertEqual(labelValue("Failing Rule"), "\(Status.inactive) Failing Rule")
        XCTAssertEqual(labelValue("Empty Rule"), "\(Status.inactive) Empty Rule")
    }

    private func labelValue(_ name: String) -> String? {
        return textInput.staticTexts[name].value as? String
    }

}
