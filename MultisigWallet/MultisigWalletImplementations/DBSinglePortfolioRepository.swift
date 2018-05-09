//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

extension Portfolio: DBCodable {}

class DBSinglePortfolioRepository: DBBaseRepository<Portfolio>, SinglePortfolioRepository {

    func portfolio() throws -> Portfolio? {
        return try findFirst()
    }

}
