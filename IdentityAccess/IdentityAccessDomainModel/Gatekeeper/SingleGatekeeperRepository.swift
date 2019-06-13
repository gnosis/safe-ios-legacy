//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

/// Represents a single persisted Gatekeeper entity.
public protocol SingleGatekeeperRepository {

    /// Persists gatekeeper
    ///
    /// - Parameter gatekeeper: gatekeeper entity
    /// - Throws: error during persisting gatekeeper
    func save(_ gatekeeper: Gatekeeper)

    /// Removes persisted gatekeeper
    ///
    /// - Parameter gatekeeper: gatekeeper entity
    /// - Throws: error during removing gatekeeper
    func remove(_ gatekeeper: Gatekeeper)

    /// Returns persisted gatekeeper, if any
    ///
    /// - Returns: gatekeeper or nil
    func gatekeeper() -> Gatekeeper?

    /// generates new gatekeeper id
    ///
    /// - Returns: new id
    func nextId() -> GatekeeperID

}
