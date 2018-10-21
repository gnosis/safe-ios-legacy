//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

@testable import SafeAppUI
import XCTest
import CommonTestSupport

class KeyboardAvoidingBehaviorTests: XCTestCase {

    let scrollView: UIScrollView = UIScrollView()
    let stubCenter: StubNotificationCenter = StubNotificationCenter()
    var behavior: KeyboardAvoidingBehavior!

    override func setUp() {
        super.setUp()
        behavior = KeyboardAvoidingBehavior(scrollView: scrollView, notificationCenter: stubCenter)
        behavior.start()
    }

    func test_onStart_observesNotification() {
        let didShowObserver = stubCenter.registry[UIResponder.keyboardDidShowNotification] as? KeyboardAvoidingBehavior
        let willHideObserver = stubCenter.registry[UIResponder.keyboardWillHideNotification]
            as? KeyboardAvoidingBehavior

        XCTAssertNotNil(didShowObserver)
        XCTAssertTrue(didShowObserver === willHideObserver)
        XCTAssertTrue(didShowObserver === behavior)
    }

    func test_onStop_removesItselfFromObservers() {

        behavior.stop()

        let didShowObserver = stubCenter.registry[UIResponder.keyboardDidShowNotification] as? KeyboardAvoidingBehavior
        let willHideObserver = stubCenter.registry[UIResponder.keyboardWillHideNotification]
            as? KeyboardAvoidingBehavior

        XCTAssertNil(didShowObserver)
        XCTAssertNil(willHideObserver)
    }

    func test_whenKeyboardShown_updatesScrollViewInsets() {
        let keyboardFrame = CGRect(x: 0, y: 0, width: 100, height: 100)
        let notification = NSNotification(name: UIResponder.keyboardDidShowNotification,
                                          object: nil,
                                          userInfo: [UIResponder.keyboardFrameEndUserInfoKey:
                                            NSValue(cgRect: keyboardFrame)])
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(scrollView)
        }

        behavior.didShowKeyboard(notification)

        XCTAssertEqual(scrollView.contentInset.bottom, keyboardFrame.height)
        XCTAssertEqual(scrollView.scrollIndicatorInsets.bottom, keyboardFrame.height)
    }

    func test_whenKeyboardFrameIsMissingFromNotification_doesNothing() {
        let notification = NSNotification(name: UIResponder.keyboardDidShowNotification,
                                          object: nil,
                                          userInfo: [:])
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(scrollView)
        }

        scrollView.contentInset.bottom = 15

        behavior.didShowKeyboard(notification)

        XCTAssertEqual(scrollView.contentInset.bottom, 15)
        XCTAssertEqual(scrollView.scrollIndicatorInsets.bottom, 0)
    }

    func test_whenScrollViewOffScreen_doesNothing() {
        let keyboardFrame = CGRect(x: 0, y: 0, width: 100, height: 100)
        let notification = NSNotification(name: UIResponder.keyboardDidShowNotification,
                                          object: nil,
                                          userInfo: [UIResponder.keyboardFrameEndUserInfoKey:
                                            NSValue(cgRect: keyboardFrame)])
        scrollView.contentInset.bottom = 15

        behavior.didShowKeyboard(notification)

        XCTAssertEqual(scrollView.contentInset.bottom, 15)
        XCTAssertEqual(scrollView.scrollIndicatorInsets.bottom, 0)
    }

    // FIXME: different expected values for different simulators
//    func test_whenActiveFieldPresentAndOutOfVisibleArea_scrollsToIt() {
//        let keyboardFrame = CGRect(x: 0, y: 0, width: 100, height: 50)
//        let notification = NSNotification(name: UIResponder.keyboardDidShowNotification,
//                                          object: nil,
//                                          userInfo: [UIResponder.keyboardFrameEndUserInfoKey:
//                                            NSValue(cgRect: keyboardFrame),
//                                                     "suppress_animation": true])
//        scrollView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
//
//        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 5_000))
//        let textField = UITextField(frame: CGRect(x: 0, y: 2_500, width: 100, height: 40))
//
//        contentView.addSubview(textField)
//        scrollView.addSubview(contentView)
//        scrollView.contentSize = contentView.bounds.size
//
//        behavior.activeTextField = textField
//
//        if let window = UIApplication.shared.keyWindow {
//            window.addSubview(scrollView)
//        }
//
//        behavior.didShowKeyboard(notification)
//        delay()
//        XCTAssertEqual(scrollView.contentOffset.y, 2_520)
//    }

    func test_didHideKeyboard_resetsInsets() {
        scrollView.contentInset.bottom = 1
        scrollView.scrollIndicatorInsets.bottom = 1

        behavior.didHideKeyboard(NSNotification(name: UIResponder.keyboardWillHideNotification, object: nil))

        XCTAssertEqual(scrollView.contentInset.bottom, 0)
        XCTAssertEqual(scrollView.scrollIndicatorInsets.bottom, 0)
    }

}

class StubNotificationCenter: NotificationCenter {

    var registry: [NSNotification.Name: Any] = [:]

    override func addObserver(_ observer: Any,
                              selector aSelector: Selector,
                              name aName: NSNotification.Name?,
                              object anObject: Any?) {
        if let name = aName {
            registry[name] = observer
        }
    }

    override func removeObserver(_ observer: Any, name aName: NSNotification.Name?, object anObject: Any?) {
        if let name = aName {
            registry.removeValue(forKey: name)
        } else {
            let tuples = registry.filter { ($0.value as? AnyClass) === (observer as? AnyClass) }
            tuples.forEach { registry.removeValue(forKey: $0.key) }
        }
    }

}
