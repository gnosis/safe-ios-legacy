//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

public class InMemorySinglePortfolioRepository: SinglePortfolioRepository {

    private var savedValue: Portfolio?

    public init() {}

    public func save(_ portfolio: Portfolio) throws {
        savedValue = portfolio
    }

    public func remove(_ portfolio: Portfolio) throws {
        savedValue = nil
    }

    public func portfolio() throws -> Portfolio? {
        return savedValue
    }

    public func nextID() throws -> PortfolioID {
        return PortfolioID()
    }

}
