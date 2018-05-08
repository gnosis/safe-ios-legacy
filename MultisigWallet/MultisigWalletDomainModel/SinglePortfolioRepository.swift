//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public protocol SinglePortfolioRepository {

    func save(_ portfolio: Portfolio) throws
    func remove(_ portfolioID: PortfolioID) throws
    func portfolio() throws -> Portfolio?

}
