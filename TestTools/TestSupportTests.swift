//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
@testable import safe

class TestSupportTests: AbstractAppTestCase {

    let support = TestSupport()

    override func setUp() {
        super.setUp()
        // TODO: pull up
        ApplicationServiceRegistry.put(service: authenticationService,
                                       for: AuthenticationApplicationService.self)
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
        XCTAssertTrue(authenticationService.didRequestUserRegistration)
    }

    func test_setUp_whenSetPasswordWithoutNewPassword_thenDoesNothing() {
        support.setUp([ApplicationArguments.setPassword])
        XCTAssertFalse(authenticationService.didRequestUserRegistration)
    }

    func test_setUp_whenSessionDurationProvided_thenSetsSessionDuration() {
        support.setUp([ApplicationArguments.setSessionDuration, "1.0"])
        XCTAssertEqual(authenticationService.sessionDuration, 1)
    }

    func test_setUp_whenSessionDurationWithoutValue_thenDoesNothing() {
        authenticationService.configureSession(1)
        support.setUp([ApplicationArguments.setSessionDuration, "invalid"])
        XCTAssertEqual(authenticationService.sessionDuration, 1)
    }

    func test_setUp_whenSetMaxPasswordAttemptsProvided_thenSetsMaxAttempts() {
        authenticationService.configureMaxPasswordAttempts(0)
        support.setUp([ApplicationArguments.setMaxPasswordAttempts, "1"])
        XCTAssertEqual(authenticationService.maxPasswordAttempts, 1)
    }

    func test_setUp_whenSetMaxPasswordAttemptsInvalid_thenDoesNothing() {
        authenticationService.configureMaxPasswordAttempts(3)
        support.setUp([ApplicationArguments.setMaxPasswordAttempts, "invalid"])
        XCTAssertEqual(authenticationService.maxPasswordAttempts, 3)
    }

    func test_setUp_whenBlockedPeriodDurationSet_thenAccountChanged() {
        authenticationService.configureBlockDuration(1)
        support.setUp([ApplicationArguments.setAccountBlockedPeriodDuration, "10.1"])
        XCTAssertEqual(authenticationService.blockedPeriodDuration, 10.1)
    }

    func test_setUp_whenBlockedPeriodDurationInvalid_thenDoesNothing() {
        authenticationService.configureBlockDuration(3)
        support.setUp([ApplicationArguments.setAccountBlockedPeriodDuration, "invalid"])
        XCTAssertEqual(authenticationService.blockedPeriodDuration, 3)
    }

}

final class MockResettable: Resettable {

    var didReset = false

    func resetAll() {
        didReset = true
    }

}
