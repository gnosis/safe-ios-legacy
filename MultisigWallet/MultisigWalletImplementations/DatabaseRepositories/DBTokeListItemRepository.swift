//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Database
import MultisigWalletDomainModel

public class DBTokenListItemRepository: TokenListItemRepository {

    struct SQL {
        static let createTable = """
CREATE TABLE IF NOT EXISTS tbl_token_list_items (
    id TEXT NOT NULL PRIMARY KEY,
    token TEXT NOT NULL,
    status TEXT NOT NULL,
    can_pay_transaction_fee BOOLEAN,
    sorting_id INTEGER,
    updated TEXT NOT NULL
);
"""
        static let insert = "INSERT OR REPLACE INTO tbl_token_list_items VALUES (?, ?, ?, ?, ?, ?);"
        static let delete = "DELETE FROM tbl_token_list_items WHERE id = ?;"
        static let find = """
SELECT id, token, status, can_pay_transaction_fee, sorting_id, updated
FROM tbl_token_list_items
WHERE id = ?
ORDER BY rowid
LIMIT 1;
"""
        static let all = """
SELECT id, token, status, can_pay_transaction_fee, sorting_id, updated
FROM tbl_token_list_items ORDER BY token;
"""
        static let find_by_status = """
SELECT id, token, status, can_pay_transaction_fee, sorting_id, updated
FROM tbl_token_list_items
WHERE status = ?
ORDER BY sorting_id;
"""

    }

    private let db: Database

    public init(db: Database) {
        self.db = db
    }

    public func setUp() {
        try! db.execute(sql: SQL.createTable)
    }

    public func save(_ tokenListItem: TokenListItem) {
        prepareToSave(tokenListItem)
        doSave(tokenListItem)
    }

    private func doSave(_ tokenListItem: TokenListItem) {
        try! db.execute(sql: SQL.insert, bindings: [
            tokenListItem.id.id,
            tokenListItem.token.description,
            tokenListItem.status.rawValue,
            tokenListItem.canPayTransactionFee,
            tokenListItem.sortingId,
            DateFormatter.networkDateFormatter.string(from: tokenListItem.updated)])
    }

    public func remove(_ tokenListItem: TokenListItem) {
        try! db.execute(sql: SQL.delete, bindings: [tokenListItem.id.id])
    }

    public func find(id: TokenID) -> TokenListItem? {
        if id == Token.Ether.id { return TokenListItem(token: .Ether,
                                                       status: .whitelisted,
                                                       canPayTransactionFee: true) }
        return try! db.execute(sql: SQL.find,
                               bindings: [id.id],
                               resultMap: tokenListItemFromResultSet).first as? TokenListItem
    }

    private func tokenListItemFromResultSet(_ rs: ResultSet) -> TokenListItem? {
        guard let tokenString = rs.string(column: "token"),
            let token = Token(tokenString),
            let statusString = rs.string(column: "status"),
            let status = TokenListItem.TokenListItemStatus(rawValue: statusString),
            let canPayTransactionFee = rs.bool(column: "can_pay_transaction_fee"),
            let updatedString = rs.string(column: "updated"),
            let updated = DateFormatter.networkDateFormatter.date(from: updatedString) else { return nil }
        let sortingId = rs.int(column: "sorting_id")
        return TokenListItem(token: token,
                             status: status,
                             canPayTransactionFee: canPayTransactionFee,
                             sortingId: sortingId,
                             updated: updated)
    }

    public func all() -> [TokenListItem] {
        return try! db.execute(sql: SQL.all, resultMap: tokenListItemFromResultSet).compactMap { $0 }
    }

    public func whitelisted() -> [TokenListItem] {
        return try! db.execute(sql: SQL.find_by_status,
                               bindings: [TokenListItem.TokenListItemStatus.whitelisted.rawValue],
                               resultMap: tokenListItemFromResultSet).compactMap { $0 }
    }

}
