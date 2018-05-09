//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

extension Portfolio: DBCodable {}

public class DBSinglePortfolioRepository: DBBaseRepository<Portfolio>, SinglePortfolioRepository {

    public func portfolio() throws -> Portfolio? {
        return try findFirst()
    }

}
