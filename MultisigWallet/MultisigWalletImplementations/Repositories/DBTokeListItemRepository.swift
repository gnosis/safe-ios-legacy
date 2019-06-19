//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Database
import MultisigWalletDomainModel
import CommonImplementations

public class DBTokenListItemRepository: DBEntityRepository<TokenListItem, TokenID>, TokenListItemRepository {

    public override var table: TableSchema {
        return .init("tbl_token_list_items",
                     "id TEXT NOT NULL PRIMARY KEY",
                     "token TEXT NOT NULL",
                     "status TEXT NOT NULL",
                     "sorting_id INTEGER",
                     "updated TEXT NOT NULL",
                     "can_pay_transaction_fee BOOLEAN")
    }

    public override func insertionBindings(_ object: TokenListItem) -> [SQLBindable?] {
        return bindable([object.id,
                         object.token,
                         object.status.rawValue,
                         object.sortingId,
                         object.updated,
                         object.canPayTransactionFee])
    }

    public override func save(_ tokenListItem: TokenListItem) {
        prepareToSave(tokenListItem)
        super.save(tokenListItem)
    }

    public override func find(id: TokenID) -> TokenListItem? {
        if id == Token.Ether.id { return TokenListItem(token: .Ether,
                                                       status: .whitelisted,
                                                       canPayTransactionFee: true) }
        return super.find(id: id)
    }

    public override func objectFromResultSet(_ rs: ResultSet) throws -> TokenListItem? {
        guard let tokenString = rs.string(column: "token"),
            let token = Token(tokenString),
            let statusString = rs.string(column: "status"),
            let status = TokenListItem.TokenListItemStatus(rawValue: statusString),
            let canPayTransactionFee = rs.bool(column: "can_pay_transaction_fee") else { return nil }
        let sortingId = rs.int(column: "sorting_id")
        let updated = Date(serializedValue: rs.string(column: "updated")) ?? Date()
        return TokenListItem(token: token,
                             status: status,
                             canPayTransactionFee: canPayTransactionFee,
                             sortingId: sortingId,
                             updated: updated)
    }

    public func whitelisted() -> [TokenListItem] {
        return find(key: "status",
                    value: TokenListItem.TokenListItemStatus.whitelisted.rawValue,
                    orderBy: "sorting_id")
    }

    public func paymentTokens() -> [TokenListItem] {
        let items = find(key: "can_pay_transaction_fee",
                         value: true,
                         orderBy: "rowid")
        return items.sorted { $0.token.code < $1.token.code }
    }

}
