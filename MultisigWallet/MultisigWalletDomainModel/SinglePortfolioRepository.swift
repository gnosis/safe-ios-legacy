//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public protocol SinglePortfolioRepository {

    func save(_ portfolio: Portfolio) throws
    func remove(_ portfolio: Portfolio) throws
    func portfolio() throws -> Portfolio?

}
