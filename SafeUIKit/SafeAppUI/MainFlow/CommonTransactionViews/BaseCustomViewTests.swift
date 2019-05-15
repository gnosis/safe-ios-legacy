//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import SafeUIKit

/// This test is parametrized: it tests both TestCustomButton and TestCustomView
/// with the same set of tests because they have the same API. We have these duplicate classes
/// because we can't substitute base class of UIButton or other UIKit variant.
/// Although we could use method swizzling, but I feel it is not worth the trouble.
class BaseCustomViewTests: XCTestCase {

    var initClosure: (() -> UIView & TestCustomViewProtocol)!
    var initWithFrameClosure: ((CGRect) -> UIView & TestCustomViewProtocol)!
    var initWithCoderClosure: ((NSCoder) -> UIView & TestCustomViewProtocol)!
    var otherInit: (() -> (UIView & TestCustomViewProtocol)?)!

    override class var defaultTestSuite: XCTestSuite {
        let testSuite = XCTestSuite(name: NSStringFromClass(self))

        for invocation in testInvocations {
            var test = BaseCustomViewTests(invocation: invocation)
            test.initClosure = { TestCustomButton() }
            test.initWithFrameClosure = { TestCustomButton(frame: $0) }
            test.initWithCoderClosure = { TestCustomButton(coder: $0)! }
            test.otherInit = { TestCustomButton(type: .custom) }
            testSuite.addTest(test)

            test = BaseCustomViewTests(invocation: invocation)
            test.initClosure = { TestCustomView() }
            test.initWithFrameClosure = { TestCustomView(frame: $0) }
            test.initWithCoderClosure = { TestCustomView(coder: $0)! }
            test.otherInit = { nil }
            testSuite.addTest(test)
        }

        return testSuite
    }

    func test_whenInited_thenCallsCommonInit() {
        let button = initClosure()
        XCTAssertTrue(button.didCallCommonInit)
    }

    func test_whenInitWithFrame_thenCallsCommonInit() {
        let button = initWithFrameClosure(CGRect.zero)
        XCTAssertTrue(button.didCallCommonInit)
    }

    func test_whenInitWithType_thenCallsCommonInit() {
        guard let button = otherInit() else { return }
        XCTAssertTrue(button.didCallCommonInit)
    }

    func test_whenInitWithCoder_thenCallsCommonInit() {
        let button = initWithCoderClosure(dummyCoder())
        button.awakeFromNib()
        XCTAssertTrue(button.didCallCommonInit)
    }

    func test_whenLoaded_thenCallsUpdate() {
        let button = initClosure()
        button.update()
        XCTAssertTrue(button.didCallUpdate)
    }

}

extension BaseCustomViewTests {

    private func dummyCoder() -> NSCoder {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode("Hello", forKey: "world")
        let coder = NSKeyedUnarchiver(forReadingWith: data as Data)
        return coder
    }

}

protocol TestCustomViewProtocol {

    var didCallCommonInit: Bool { get set }
    var didCallUpdate: Bool { get set }

    func commonInit()
    func update()

}

class TestCustomButton: BaseCustomButton, TestCustomViewProtocol {

    var didCallCommonInit = false
    var didCallUpdate = false

    override func commonInit() {
        didCallCommonInit = true
    }

    override func update() {
        didCallUpdate = true
    }

}

class TestCustomView: BaseCustomView, TestCustomViewProtocol {

    var didCallCommonInit = false
    var didCallUpdate = false

    override func commonInit() {
        didCallCommonInit = true
    }

    override func update() {
        didCallUpdate = true
    }

}
