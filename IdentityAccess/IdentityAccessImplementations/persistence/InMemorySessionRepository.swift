//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import IdentityAccessDomainModel

public class InMemorySessionRepository: SessionRepository {

    private var session: XSession?
    private var configuration: SessionConfiguration?

    public init() {}

    public func save(_ session: XSession) throws {
        self.session = session
    }

    public func latestSession() -> XSession? {
        return session
    }

    public func nextId() -> SessionID {
        do {
            return try SessionID(String(repeating: "a", count: 36))
        } catch let e {
            preconditionFailure("Failed to create session ID: \(e)")
        }
    }

    public func save(_ configuration: SessionConfiguration) throws {
        self.configuration = configuration
    }

    public func sessionConfiguration() -> SessionConfiguration? {
        return configuration
    }

}
