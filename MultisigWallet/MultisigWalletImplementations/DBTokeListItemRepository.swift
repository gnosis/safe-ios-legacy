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
    sorting_id INTEGER,
    updated TEXT NOT NULL
);
"""
        static let insert = "INSERT OR REPLACE INTO tbl_token_list_items VALUES (?, ?, ?, ?, ?);"
        static let delete = "DELETE FROM tbl_token_list_items WHERE id = ?;"
        static let find = """
SELECT id, token, status, sorting_id, updated
FROM tbl_token_list_items
WHERE id = ? LIMIT 1;
"""
        static let all = "SELECT id, token, status, sorting_id, updated FROM tbl_token_list_items;"
        static let find_by_status = """
SELECT id, token, status, sorting_id, updated
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
            tokenListItem.sortingId,
            DateFormatter.networkDateFormatter.string(from: tokenListItem.updated)])
    }

    public func remove(_ tokenListItem: TokenListItem) {
        try! db.execute(sql: SQL.delete, bindings: [tokenListItem.id.id])
    }

    public func find(id: TokenID) -> TokenListItem? {
        if id == Token.Ether.id { return TokenListItem(token: .Ether, status: .whitelisted) }
        return try! db.execute(sql: SQL.find,
                               bindings: [id.id],
                               resultMap: tokenListItemFromResultSet).first as? TokenListItem
    }

    private func tokenListItemFromResultSet(_ rs: ResultSet) -> TokenListItem? {
        guard let tokenString = rs.string(at: 1),
            let token = Token(tokenString),
            let statusString = rs.string(at: 2),
            let status = TokenListItem.TokenListItemStatus(rawValue: statusString),
            let updatedString = rs.string(at: 4),
            let updated = DateFormatter.networkDateFormatter.date(from: updatedString) else { return nil }
        let sortingId = rs.int(at: 3)
        return TokenListItem(token: token, status: status, sortingId: sortingId, updated: updated)
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
