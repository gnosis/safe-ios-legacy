//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import IdentityAccessDomainModel

/// In-memory storage of a gatekeeper entity.
public class InMemoryGatekeeperRepository: SingleGatekeeperRepository {

    private var _gatekeeper: Gatekeeper?

    public init() {}

    public func gatekeeper() -> Gatekeeper? {
        return _gatekeeper
    }

    public func save(_ keeper: Gatekeeper) {
        _gatekeeper = keeper
    }

    public func remove(_ gatekeeper: Gatekeeper) {
        guard gatekeeper == _gatekeeper else { return }
        _gatekeeper = nil
    }

    public func nextId() -> GatekeeperID {
        return GatekeeperID()
    }

}
