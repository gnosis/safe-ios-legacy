//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class TestSupportTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func test_setUp_whenResetFlagIsSet_thenResetsAllAddedObjects() {
        let mockResettable = MockResettable()
        let otherResettable = MockResettable()
        let arguments = [ApplicationArguments.resetAllContentAndSettings]
        let support = TestSupport()
        support.addResettable(mockResettable)
        support.addResettable(otherResettable)
        support.setUp(arguments)
        XCTAssertTrue(mockResettable.didReset)
        XCTAssertTrue(otherResettable.didReset)
    }

    func test_setUp_whenNoResetFlagProvided_thenDoesNotReset() {
        let mockResettable = MockResettable()
        let support = TestSupport()
        support.addResettable(mockResettable)
        support.setUp([])
        XCTAssertFalse(mockResettable.didReset)
    }

    func test_setUp_whenSetPasswordFlagIsSet_thenSetsPassword() {
        let account = MockAccount()
        let support = TestSupport(account: account)
        support.setUp([ApplicationArguments.setPassword, "a"])
        XCTAssertEqual(account.masterPassword, "a")
    }

    func test_setUp_whenSetPasswordWithoutNewPassword_thenDoesNothing() {
        let account = MockAccount()
        let support = TestSupport(account: account)
        account.masterPassword = "some"
        support.setUp([ApplicationArguments.setPassword])
        XCTAssertEqual(account.masterPassword, "some")
    }

}

final class MockResettable: Resettable {

    var didReset = false

    func resetAll() {
        didReset = true
    }

}
