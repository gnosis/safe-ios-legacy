//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

/// This test is parametrized: it tests both TestDesignableButton and TestDesignableView
/// with the same set of tests because they have the same API. We have these duplicate classes
/// because we can't substitute base class of UIButton or other designable variant.
/// Although we could use method swizzling, but I feel it is not worth the trouble.
class DesignableTests: XCTestCase {

    var initClosure: (() -> UIView & TestDesignable)!
    var initWithFrameClosure: ((CGRect) -> UIView & TestDesignable)!
    var initWithCoderClosure: ((NSCoder) -> UIView & TestDesignable)!
    var otherInit: (() -> (UIView & TestDesignable)?)!

    override class var defaultTestSuite: XCTestSuite {
        let testSuite = XCTestSuite(name: NSStringFromClass(self))

        for invocation in testInvocations {
            var test = DesignableTests(invocation: invocation)
            test.initClosure = { TestDesignableButton() }
            test.initWithFrameClosure = { TestDesignableButton(frame: $0) }
            test.initWithCoderClosure = { TestDesignableButton(coder: $0)! }
            test.otherInit = { TestDesignableButton(type: .custom) }
            testSuite.addTest(test)

            test = DesignableTests(invocation: invocation)
            test.initClosure = { TestDesignableView() }
            test.initWithFrameClosure = { TestDesignableView(frame: $0) }
            test.initWithCoderClosure = { TestDesignableView(coder: $0)! }
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

    func test_whenNotLoaded_thenDoesNotUpdate() {
        let button = initClosure()
        button.setNeedsUpdate()
        XCTAssertFalse(button.didCallUpdate)
    }

    func test_whenLoaded_thenCallsUpdate() {
        let button = initClosure()
        button.didLoad()
        XCTAssertTrue(button.didCallUpdate)
    }

    func test_whenPreapringForIB_thenCallsUpdate() {
        let button = initClosure()
        button.didLoad()
        button.prepareForInterfaceBuilder()
        XCTAssertTrue(button.didCallUpdate)
    }

    func test_whenNotLoadedAndPreparingForIB_thenDoesNotUpdate() {
        let button = initClosure()
        button.prepareForInterfaceBuilder()
        XCTAssertFalse(button.didCallUpdate)
    }

}

extension DesignableTests {

    private func dummyCoder() -> NSCoder {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode("Hello", forKey: "world")
        let coder = NSKeyedUnarchiver(forReadingWith: data as Data)
        return coder
    }

}

protocol TestDesignable {

    var didCallCommonInit: Bool { get set }
    var didCallUpdate: Bool { get set }

    func commonInit()
    func update()
    func setNeedsUpdate()
    func didLoad()

}

class TestDesignableButton: DesignableButton, TestDesignable {

    var didCallCommonInit = false
    var didCallUpdate = false

    override func commonInit() {
        didCallCommonInit = true
    }

    override func update() {
        didCallUpdate = true
    }

}

class TestDesignableView: DesignableView, TestDesignable {

    var didCallCommonInit = false
    var didCallUpdate = false

    override func commonInit() {
        didCallCommonInit = true
    }

    override func update() {
        didCallUpdate = true
    }

}
