//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public protocol SinglePortfolioRepository {

    func save(_ portfolio: Portfolio)
    func remove(_ portfolio: Portfolio)
    func portfolio() -> Portfolio?
    func nextID() -> PortfolioID

}
