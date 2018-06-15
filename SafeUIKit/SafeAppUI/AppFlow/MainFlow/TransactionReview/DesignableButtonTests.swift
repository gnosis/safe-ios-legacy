//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class DesignableButtonTests: XCTestCase {

    var buttonInit: () -> TestDesignableButton = {
        return TestDesignableButton()
    }

    func test_whenInited_thenCallsCommonInit() {
        let button = TestDesignableButton()
        XCTAssertTrue(button.didCallCommonInit)
    }

    func test_whenInitWithFrame_thenCallsCommonInit() {
        let button = TestDesignableButton(frame: CGRect.zero)
        XCTAssertTrue(button.didCallCommonInit)
    }

    func test_whenInitWithType_thenCallsCommonInit() {
        let button = TestDesignableButton(type: .custom)
        XCTAssertTrue(button.didCallCommonInit)
    }

    func test_whenInitWithCoder_thenCallsCommonInit() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode("Hello", forKey: "world")
        let coder = NSKeyedUnarchiver(forReadingWith: data as Data)
        let button = TestDesignableButton(coder: coder)!
        button.awakeFromNib()
        XCTAssertTrue(button.didCallCommonInit)
    }

    func test_whenNotLoaded_thenDoesNotUpdate() {
        let button = TestDesignableButton()
        button.setNeedsUpdate()
        XCTAssertFalse(button.didCallUpdate)
    }

    func test_whenLoaded_thenCallsUpdate() {
        let button = TestDesignableButton()
        button.didLoad()
        XCTAssertTrue(button.didCallUpdate)
    }

    func test_whenPreapringForIB_thenCallsUpdate() {
        let button = TestDesignableButton()
        button.didLoad()
        button.prepareForInterfaceBuilder()
        XCTAssertTrue(button.didCallUpdate)
    }

    func test_whenNotLoadedAndPreparingForIB_thenDoesNotUpdate() {
        let button = TestDesignableButton()
        button.prepareForInterfaceBuilder()
        XCTAssertFalse(button.didCallUpdate)
    }

}

class TestDesignableButton: DesignableButton {

    var didCallCommonInit = false
    var didCallUpdate = false

    override func commonInit() {
        didCallCommonInit = true
    }

    override func update() {
        didCallUpdate = true
    }

}
