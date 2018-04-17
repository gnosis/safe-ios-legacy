//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import IdentityAccessDomainModel

class XSessionTests: XCTestCase {

    var session: Session!

    override func setUp() {
        super.setUp()
        XCTAssertNoThrow(try createSession())
    }

    func test_createsID() {
        XCTAssertNotNil(session.id)
    }

    func test_invalidIDThrows() {
        XCTAssertThrowsError(try SessionID("ID")) {
            XCTAssertEqual($0 as? SessionID.Error, .invalidID)
        }
    }

    func test_createWithDuration() throws {
        XCTAssertFalse(session.isActiveAt(Date()))
    }

    func test_durationMustBePositive() {
        assertThrows(try createSession(duration: -1), .invalidDuration)
        assertThrows(try createSession(duration: 0), .invalidDuration)
    }

    func test_start_whenBegan_thenActive() throws {
        try createSession(duration: 2)
        try session.start(Date())
        XCTAssertTrue(session.isActiveAt(Date(timeIntervalSinceNow: 1)))
    }

    func test_start_whenAlreadyBegan_thenThrows() throws {
        try session.start(Date())
        assertThrows(try session.start(Date()), .sessionWasActiveAlready)
    }

    func test_start_whenFinished_thenThrows() throws {
        try session.start(Date())
        try session.finish(Date())
        assertThrows(try session.start(Date()), .sessionWasFinishedAlready)
    }

    func test_finish_whenNotStarted_thenThrows() throws {
        assertThrows(try session.finish(Date()), .sessionIsNotActive)
    }

    func test_finish_whenFinishedAlready_thenThrows() throws {
        try session.start(Date())
        try session.finish(Date())
        assertThrows(try session.finish(Date()), .sessionIsNotActive)
    }

    func test_finish_whenExpired_thenThrows() throws {
        try session.start(Date())
        assertThrows(try session.finish(Date(timeIntervalSinceNow: 3)), .sessionIsNotActive)
    }

    func test_renew_onlyIfStarted() throws {
        assertThrows(try session.renew(Date()), .sessionIsNotActive)
    }

    func test_renew_extendsSessionLifetime() throws {
        try createSession(duration: 2)
        try session.start(Date())
        try session.renew(Date(timeIntervalSinceNow: 1))
        XCTAssertTrue(session.isActiveAt(Date(timeIntervalSinceNow: 2)))
    }

}

extension XSessionTests {

    private func createSession(duration: TimeInterval = 1) throws {
        session = try Session(id: try SessionID(UUID().uuidString), durationInSeconds: duration)
    }

    private func assertThrows<T>(_ expression: @autoclosure () throws -> T,
                                 _ error: Session.Error,
                                 line: UInt = #line) {
        XCTAssertThrowsError(try expression()) {
            XCTAssertEqual($0 as? Session.Error, error)
        }
    }

}
