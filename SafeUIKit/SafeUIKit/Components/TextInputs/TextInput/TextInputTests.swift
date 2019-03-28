//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit
import CommonTestSupport

class TextInputTests: XCTestCase {

    let textInput = StubTextInput()

    func test_whenInitialized_thenDefaultValuesAreCorrect() {
        XCTAssertEqual(textInput.placeholder, nil)
        XCTAssertEqual(textInput.style, .white)
        XCTAssertEqual(textInput.leftImage, nil)
        XCTAssertEqual(textInput.leftImageURL, nil)
        XCTAssertEqual(textInput.font, UIFont.systemFont(ofSize: 17))
        XCTAssertEqual(textInput.layer.borderColor, UIColor.white.cgColor)
        XCTAssertEqual(textInput.layer.cornerRadius, 6)
        XCTAssertEqual(textInput.layer.borderWidth, 1)
        XCTAssertNil(textInput.rightView)
        XCTAssertEqual(textInput.text, "")
    }

    func test_whenLeftImageIsSet_thenLeftViewIsDisplayed() {
        XCTAssertNil(textInput.leftView)
        textInput.leftImage = UIImage()
        XCTAssertNotNil(textInput.leftView)
    }

    func test_whenLeftImageIsNotSet_thenLeftImageURLDoesNothing() {
        textInput.leftImageURL = URL(string: "")
        XCTAssertFalse(textInput.didUpdate)
    }

    func test_whenLeftImageIsSet_thenLeftImageURLSetsANewImage() {
        textInput.leftImage = UIImage()
        textInput.leftImageURL = URL(string: "")
        XCTAssertTrue(textInput.didUpdate)
    }

    func test_whenPlaceholderIsSet_thenDiplaysIt() {
        XCTAssertNil(textInput.attributedPlaceholder)
        textInput.placeholder = "placeholder"
        XCTAssertNotNil(textInput.attributedPlaceholder)
    }

    func test_whenShowsClearButton_thenItPresent() {
        XCTAssertNil(textInput.rightView)
        textInput.hideClearButton = false
        XCTAssertTrue(textInput.rightView is UIButton)
    }

}

class StubTextInput: TextInput {

    var didUpdate = false

    override func updateImageView(url: URL?) {
        didUpdate = true
    }

}
