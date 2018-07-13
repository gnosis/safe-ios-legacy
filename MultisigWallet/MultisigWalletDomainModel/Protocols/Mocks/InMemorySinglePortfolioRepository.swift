//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

public class InMemorySinglePortfolioRepository: SinglePortfolioRepository {

    private var savedValue: Portfolio?

    public init() {}

    public func save(_ portfolio: Portfolio) {
        savedValue = portfolio
    }

    public func remove(_ portfolio: Portfolio) {
        savedValue = nil
    }

    public func portfolio() -> Portfolio? {
        return savedValue
    }

    public func nextID() -> PortfolioID {
        return PortfolioID()
    }

}
