//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import CommonTestSupport

class RBEIntroViewControllerTests: XCTestCase {

    let vc = RBEIntroViewController.create()

    override func setUp() {
        super.setUp()
        vc.loadViewIfNeeded()
    }

    func test_whenStarts_thenInLoading() {
        XCTAssertState(RBEIntroViewController.LoadingState.self)
    }

    func test_whenErrorDuringLoading_thenInvalid() {
        vc.handleError(TestError.error)
        XCTAssertState(RBEIntroViewController.InvalidState.self)
    }

    func test_whenBackDuringLoading_thenCancelling() {
        vc.back()
        XCTAssertState(RBEIntroViewController.CancellingState.self)
    }

    func test_whenLoadedSuccessfully_thenReady() {
        vc.didLoad()
        XCTAssertState(RBEIntroViewController.ReadyState.self)
    }

    func test_whenBackDuringReady_thenCancelling() {
        vc.state = RBEIntroViewController.ReadyState()
        vc.back()
        XCTAssertState(RBEIntroViewController.CancellingState.self)
    }

    func test_whenStartDuringReady_thenStarting() {
        vc.transition(to: RBEIntroViewController.ReadyState())
        vc.start()
        XCTAssertState(RBEIntroViewController.StartingState.self)
    }

    func test_whenStartedSuccessfully_thenStarted() {
        vc.transition(to: RBEIntroViewController.StartingState())
        vc.didStart()
        XCTAssertState(RBEIntroViewController.StartedState.self)
    }

    func test_whenErrorDuringStarting_thenError() {
        vc.transition(to: RBEIntroViewController.StartingState())
        vc.handleError(TestError.error)
        XCTAssertState(RBEIntroViewController.ErrorState.self)
    }

    func test_whenRetryDuringError_thenLoading() {
        vc.transition(to: RBEIntroViewController.ErrorState())
        vc.retry()
        XCTAssertState(RBEIntroViewController.LoadingState.self)
    }

    func test_whenBackDuringError_thenCancelling() {
        vc.transition(to: RBEIntroViewController.ErrorState())
        vc.back()
        XCTAssertState(RBEIntroViewController.CancellingState.self)
    }

    func test_whenBackDuringInvalid_thenCancelling() {
        vc.transition(to: RBEIntroViewController.InvalidState())
        vc.back()
        XCTAssertState(RBEIntroViewController.CancellingState.self)
    }

    func test_whenRetryDuringInvalid_thenLoading() {
        vc.transition(to: RBEIntroViewController.InvalidState())
        vc.retry()
        XCTAssertState(RBEIntroViewController.LoadingState.self)
    }

}

extension RBEIntroViewControllerTests {

    func XCTAssertState<T: RBEIntroViewController.State>(_ expectedState: T.Type,
                                                         file: StaticString = #file,
                                                         line: UInt = #line) {
        XCTAssertTrue(vc.state is T, "Unexpected state: \(vc.state)", file: file, line: line)
    }

}
