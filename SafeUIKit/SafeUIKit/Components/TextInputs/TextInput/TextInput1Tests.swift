//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit

class TextInput1Tests: XCTestCase {

    let textInput = TextInput1()

    func test_whenInitialized_thenDefaultValuesAreCorrect() {
        XCTAssertEqual(textInput.placeholder, nil)
        XCTAssertEqual(textInput.isDimmed, false)
        XCTAssertEqual(textInput.leftImage, nil)
        XCTAssertEqual(textInput.font, UIFont.systemFont(ofSize: 17))
        XCTAssertEqual(textInput.layer.borderColor, UIColor.white.cgColor)
        XCTAssertEqual(textInput.layer.cornerRadius, 6)
        XCTAssertEqual(textInput.layer.borderWidth, 1)
        XCTAssertTrue(textInput.rightView is UIButton)
    }

    func test_whenLeftImageIsSet_thenLeftViewIsDisplayed() {
        XCTAssertNil(textInput.leftView)
        textInput.leftImage = UIImage()
        XCTAssertNotNil(textInput.leftView)
    }

    func test_whenPlaceholderIsSet_thenDiplaysIt() {
        XCTAssertNil(textInput.attributedPlaceholder)
        textInput.placeholder = "placeholder"
        XCTAssertNotNil(textInput.attributedPlaceholder)
    }

}
