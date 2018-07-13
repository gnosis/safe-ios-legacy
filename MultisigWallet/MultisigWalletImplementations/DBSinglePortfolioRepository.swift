//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

extension Portfolio: DBCodable {}

public class DBSinglePortfolioRepository: DBBaseRepository<Portfolio>, SinglePortfolioRepository {

    public override var tableName: String {
        return "tbl_portfolios"
    }

    public func portfolio() -> Portfolio? {
        return findFirst()
    }

}
