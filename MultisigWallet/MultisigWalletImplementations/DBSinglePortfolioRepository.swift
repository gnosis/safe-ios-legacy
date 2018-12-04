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
        return [
            object.id.id,
            object.wallets.map { $0.id }.joined(separator: ","),
            object.selectedWallet?.id]
    }

    override public func objectFromResultSet(_ rs: ResultSet) -> Portfolio? {
        let it = rs.rowIterator()
        let id = it.nextString()
        let wallets = it.nextString()
        let selected = it.nextString()
        guard id != nil && wallets != nil else { return nil }
        let portfolio = Portfolio(id: PortfolioID(id!),
                                  wallets: wallets!.components(separatedBy: ",").map { WalletID($0) },
                                  selectedWallet: selected == nil ? nil : WalletID(selected!))
        return portfolio
    }

}
