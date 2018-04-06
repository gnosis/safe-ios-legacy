//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class TestSupportTests: AbstractAppTestCase {

    let support = TestSupport()

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

    func test_setUp_whenSetMaxPasswordAttemptsProvided_thenSetsMaxAttempts() {
        account.maxPasswordAttempts = 0
        support.setUp([ApplicationArguments.setMaxPasswordAttempts, "1"])
        XCTAssertEqual(account.maxPasswordAttempts, 1)
    }

    func test_setUp_whenSetMaxPasswordAttemptsInvalid_thenDoesNothing() {
        account.maxPasswordAttempts = 3
        support.setUp([ApplicationArguments.setMaxPasswordAttempts, "invalid"])
        XCTAssertEqual(account.maxPasswordAttempts, 3)
    }

    func test_setUp_whenBlockedPeriodDurationSet_thenAccountChanged() {
        account.blockedPeriodDuration = 1
        support.setUp([ApplicationArguments.setAccountBlockedPeriodDuration, "10.1"])
        XCTAssertEqual(account.blockedPeriodDuration, 10.1)
    }

    func test_setUp_whenBlockedPeriodDurationInvalid_thenDoesNothing() {
        account.blockedPeriodDuration = 3
        support.setUp([ApplicationArguments.setAccountBlockedPeriodDuration, "invalid"])
        XCTAssertEqual(account.blockedPeriodDuration, 3)
    }

}

final class MockResettable: Resettable {

    var didReset = false

    func resetAll() {
        didReset = true
    }

}
