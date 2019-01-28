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
        assertState(RBEIntroViewController.LoadingState.self)
    }

    func test_whenErrorDuringLoading_thenInvalid() {
        vc.handleError(TestError.error)
        assertState(RBEIntroViewController.InvalidState.self)
    }

    func test_whenBackDuringLoading_thenCancelling() {
        vc.back()
        assertState(RBEIntroViewController.CancellingState.self)
    }

    func test_whenLoadedSuccessfully_thenReady() {
        vc.didLoad()
        assertState(RBEIntroViewController.ReadyState.self)
    }

    func test_whenBackDuringReady_thenCancelling() {
        vc.state = RBEIntroViewController.ReadyState()
        vc.back()
        assertState(RBEIntroViewController.CancellingState.self)
    }

    func test_whenStartDuringReady_thenStarting() {
        vc.state = RBEIntroViewController.ReadyState()
        vc.start()
        assertState(RBEIntroViewController.StartingState.self)
    }

    func test_whenStartedSuccessfully_thenStarted() {
        vc.state = RBEIntroViewController.StartingState()
        vc.didStart()
        assertState(RBEIntroViewController.StartedState.self)
    }

    func test_whenErrorDuringStarting_thenError() {
        vc.state = RBEIntroViewController.StartingState()
        vc.handleError(TestError.error)
        assertState(RBEIntroViewController.ErrorState.self)
    }

    func test_whenRetryDuringError_thenLoading() {
        vc.state = RBEIntroViewController.ErrorState()
        vc.retry()
        assertState(RBEIntroViewController.LoadingState.self)
    }

    func test_whenBackDuringError_thenCancelling() {
        vc.state = RBEIntroViewController.ErrorState()
        vc.back()
        assertState(RBEIntroViewController.CancellingState.self)
    }

    func test_whenBackDuringInvalid_thenCancelling() {
        vc.state = RBEIntroViewController.InvalidState()
        vc.back()
        assertState(RBEIntroViewController.CancellingState.self)
    }

    func test_whenRetryDuringInvalid_thenLoading() {
        vc.state = RBEIntroViewController.InvalidState()
        vc.retry()
        assertState(RBEIntroViewController.LoadingState.self)
    }

}

extension RBEIntroViewControllerTests {

    func assertState<T: RBEIntroViewController.State>(_ expectedState: T.Type,
                                                      file: StaticString = #file,
                                                      line: UInt = #line) {
        XCTAssertTrue(vc.state is T, "Unexpected state: \(vc.state)", file: file, line: line)
    }
}
