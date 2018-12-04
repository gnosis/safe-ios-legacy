//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import Database

public class DBSinglePortfolioRepository: DBEntityRepository<Portfolio, PortfolioID>, SinglePortfolioRepository {

    public func portfolio() -> Portfolio? {
        return findFirst()
    }

    override public var table: TableSchema {
        return .init("tbl_portfolios",
                     "id TEXT NOT NULL PRIMARY KEY",
                     "wallets TEXT NOT NULL",
                     "selected_wallet TEXT")
    }

    override public func insertionBindings(_ object: Portfolio) -> [SQLBindable?] {
        return bindable([object.id,
                         object.wallets,
                         object.selectedWallet])
    }

    override public func objectFromResultSet(_ rs: ResultSet) -> Portfolio? {
        guard let id: String = rs["id"],
            let wallets: String = rs["wallets"] else { return nil }
        let selectedWallet: String? = rs["selected_wallet"]
        let portfolio = Portfolio(id: PortfolioID(id),
                                  wallets: WalletIDList(serializedString: wallets),
                                  selectedWallet: WalletID(serializedString: selectedWallet))
        return portfolio
    }

}
