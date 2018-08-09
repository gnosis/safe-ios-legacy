//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

/// Represents a single Portfolio
public protocol SinglePortfolioRepository {

    /// Persists portfolio
    ///
    /// - Parameter portfolio: portfolio to save
    func save(_ portfolio: Portfolio)

    /// Removes existing portfolio
    ///
    /// - Parameter portfolio: portfolio to remove
    func remove(_ portfolio: Portfolio)

    /// Finds single portfolio, if it exists
    ///
    /// - Returns: existing portfolio or nil
    func portfolio() -> Portfolio?

    /// Generates new portfolio identifier
    ///
    /// - Returns: new identifier
    func nextID() -> PortfolioID

}
