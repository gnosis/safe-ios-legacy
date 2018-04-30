//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import IdentityAccessDomainModel

class GatekeeperTests: DomainTestCase {

    var gatekeeper: Gatekeeper!
    var policy: AuthenticationPolicy!

    override func setUp() {
        super.setUp()
        XCTAssertNoThrow(
            policy = try AuthenticationPolicy(sessionDuration: 2,
                                              maxFailedAttempts: 2,
                                              blockDuration: 1))
        XCTAssertNoThrow(
            gatekeeper = try Gatekeeper(id: gatekeeperRepository.nextId(), policy: policy)
        )
    }

    func test_whenAccessAllowed_thenHasAccess() throws {
        let session = try gatekeeper.allowAccess(at: Date())
        XCTAssertTrue(gatekeeper.hasAccess(session: session, at: Date()))
    }

    func test_whenAccessAllowedAgain_thenOldSessionInvalid() throws {
        let oldSession = try gatekeeper.allowAccess(at: Date())
        _ = try gatekeeper.allowAccess(at: Date())
        XCTAssertFalse(gatekeeper.hasAccess(session: oldSession, at: Date()))
    }

    func test_whenAccessDenied_thenSessionInvalidated() throws {
        let session = try gatekeeper.allowAccess(at: Date())
        gatekeeper.denyAccess(at: Date())
        XCTAssertFalse(gatekeeper.hasAccess(session: session, at: Date()))
    }

    func test_whenAccessUsed_thenSessionExtended() throws {
        let session = try gatekeeper.allowAccess(at: Date())
        try gatekeeper.useAccess(at: Date(timeIntervalSinceNow: policy.sessionDuration - 1))
        XCTAssertTrue(gatekeeper.hasAccess(session: session, at: Date(timeIntervalSinceNow: policy.sessionDuration)))
    }

    func test_whenAccessDeniedTooManyTimes_thenBlocksAccess() throws {
        blockAccess()
        XCTAssertThrowsError(try gatekeeper.allowAccess(at: Date()))
        XCTAssertThrowsError(try gatekeeper.useAccess(at: Date()))
        XCTAssertFalse(gatekeeper.isAccessPossible(at: Date()))
    }

    func test_whenBlockPeriodElapsed_thenBlockIsLifted() throws {
        blockAccess()
        XCTAssertTrue(gatekeeper.isAccessPossible(at: Date(timeIntervalSinceNow: policy.blockDuration)))
    }

    func test_whenBlockPeriodExpired_thenAllowsAccess() throws {
        blockAccess()
        let time = Date(timeIntervalSinceNow: policy.blockDuration)
        let session = try gatekeeper.allowAccess(at: time)
        XCTAssertTrue(gatekeeper.hasAccess(session: session, at: time))
    }

    func test_whenBlockPeriodExpired_andAccessDeniedAgain_thenBlocksAgain() throws {
        blockAccess()
        let time = Date(timeIntervalSinceNow: policy.blockDuration)
        gatekeeper.denyAccess(at: time)
        XCTAssertFalse(gatekeeper.isAccessPossible(at: time))
    }

    func test_whenBlockPeriodExpired_andAccessAllowed_thenBlockingStateIsReset() throws {
        blockAccess()
        let time = Date(timeIntervalSinceNow: policy.blockDuration)
        _ = try gatekeeper.allowAccess(at: time)
        gatekeeper.denyAccess(at: time)
        let session = try gatekeeper.allowAccess(at: time)
        XCTAssertTrue(gatekeeper.hasAccess(session: session, at: time))
    }

    func test_whenSessionDurationChanges_thenSessionInvalidated() throws {
        let session = try gatekeeper.allowAccess(at: Date())
        try gatekeeper.changeSessionDuration(3)
        XCTAssertFalse(gatekeeper.hasAccess(session: session, at: Date()))
    }

    func test_whenSessionDurationInvalid_thenThrows() throws {
        XCTAssertThrowsError(try gatekeeper.changeSessionDuration(0))
        XCTAssertThrowsError(try gatekeeper.changeSessionDuration(-1))
    }

    func test_whenMaxFailedAttemptsChanges_thenSessionInvalidated() throws {
        let session = try gatekeeper.allowAccess(at: Date())
        try gatekeeper.changeMaxFailedAttempts(5)
        XCTAssertFalse(gatekeeper.hasAccess(session: session, at: Date()))
    }

    func test_whenMaxFailedAttemptsInvalid_thenThrows() throws {
        XCTAssertThrowsError(try gatekeeper.changeMaxFailedAttempts(0))
        XCTAssertThrowsError(try gatekeeper.changeMaxFailedAttempts(-1))
    }

    func test_whenBlockDurationChanged_thenInvalidatesSession() throws {
        let session = try gatekeeper.allowAccess(at: Date())
        try gatekeeper.changeBlockDuration(15)
        XCTAssertFalse(gatekeeper.hasAccess(session: session, at: Date()))
    }

    func test_whenBlockDurationInvalid_thenThrows() throws {
        XCTAssertNoThrow(try gatekeeper.changeBlockDuration(0))
        XCTAssertThrowsError(try gatekeeper.changeBlockDuration(-1))
    }

    func test_codable() throws {
        let data = try gatekeeper.data()
        let other = try Gatekeeper(data: data)
        XCTAssertEqual(other, gatekeeper)
    }
}

extension GatekeeperTests {

    private func blockAccess() {
        gatekeeper.denyAccess(at: Date())
        gatekeeper.denyAccess(at: Date())
    }

}
