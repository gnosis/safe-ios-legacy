//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import IdentityAccessDomainModel

public class InMemoryGatekeeperRepository: GatekeeperRepository {

    private var _gatekeeper: Gatekeeper?

    public init() {}

    public func gatekeeper() -> Gatekeeper? {
        return _gatekeeper
    }

    public func save(_ keeper: Gatekeeper) throws {
        _gatekeeper = keeper
    }

    public func nextId() -> GatekeeperID {
        do {
            return try GatekeeperID(UUID().uuidString)
        } catch let e {
            preconditionFailure("Failed to create session ID: \(e)")
        }
    }

}
