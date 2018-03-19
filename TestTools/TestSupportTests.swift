//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class TestSupportTests: XCTestCase {

    let account = MockAccount()
    var support: TestSupport!

    override func setUp() {
        super.setUp()
        support = TestSupport(account: account)
    }

    func test_setUp_whenResetFlagIsSet_thenResetsAllAddedObjects() {
        let mockResettable = MockResettable()
        let otherResettable = MockResettable()
        let arguments = [ApplicationArguments.resetAllContentAndSettings]
        support.addResettable(mockResettable)
        support.addResettable(otherResettable)
        support.setUp(arguments)
        XCTAssertTrue(mockResettable.didReset)
        XCTAssertTrue(otherResettable.didReset)
    }

    func test_setUp_whenNoResetFlagProvided_thenDoesNotReset() {
        let mockResettable = MockResettable()
        support.addResettable(mockResettable)
        support.setUp([])
        XCTAssertFalse(mockResettable.didReset)
    }

    func test_setUp_whenSetPasswordFlagIsSet_thenSetsPassword() {
        support.setUp([ApplicationArguments.setPassword, "a"])
        XCTAssertEqual(account.masterPassword, "a")
    }

    func test_setUp_whenSetPasswordWithoutNewPassword_thenDoesNothing() {
        account.masterPassword = "some"
        support.setUp([ApplicationArguments.setPassword])
        XCTAssertEqual(account.masterPassword, "some")
    }

    func test_setUp_whenSessionDurationProvided_thenSetsSessionDuration() {
        support.setUp([ApplicationArguments.setSessionDuration, "1.0"])
        XCTAssertEqual(account.sessionDuration, 1)
    }

    func test_setUp_whenSessionDurationWithoutValue_thenDoesNothing() {
        account.sessionDuration = 1
        support.setUp([ApplicationArguments.setSessionDuration, "invalid"])
        XCTAssertEqual(account.sessionDuration, 1)
    }

}

final class MockResettable: Resettable {

    var didReset = false

    func resetAll() {
        didReset = true
    }

}
