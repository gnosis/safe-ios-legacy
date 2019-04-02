//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import Database

public class DBAccountRepository: AccountRepository {

    struct SQL {
        static let createTable = """
CREATE TABLE IF NOT EXISTS tbl_accounts (
    id TEXT NOT NULL PRIMARY KEY,
    balance TEXT
);
"""
        static let insert = "INSERT OR REPLACE INTO tbl_accounts VALUES (?, ?);"
        static let delete = "DELETE FROM tbl_accounts WHERE id = ?;"
        static let find = """
SELECT id, balance
FROM tbl_accounts
WHERE id = ?
ORDER BY rowid
LIMIT 1;
"""
        static let all = "SELECT id, balance FROM tbl_accounts;"
    }

    private let db: Database

    public init(db: Database) {
        self.db = db
    }

    public func setUp() {
        try! db.execute(sql: SQL.createTable)
    }

    public func save(_ account: Account) {
        try! db.execute(sql: SQL.insert, bindings: [account.id.id,
                                                    account.balance != nil ? String(account.balance!) : nil])
    }

    public func remove(_ account: Account) {
        try! db.execute(sql: SQL.delete, bindings: [account.id.id])
    }

    public func find(id: AccountID) -> Account? {
        return try! db.execute(sql: SQL.find,
                               bindings: [id.id],
                               resultMap: accountFromResultSet).first as? Account
    }

    public func all() -> [Account] {
        return try! db.execute(sql: SQL.all, resultMap: accountFromResultSet).compactMap { $0 }
    }

    private func accountFromResultSet(_ rs: ResultSet) -> Account? {
        guard let accountID_id = rs.string(at: 0) else { return nil }
        let balance = rs.string(at: 1)
        let accountID = AccountID(accountID_id)
        let account = Account(tokenID: accountID.tokenID,
                              walletID: accountID.walletID,
                              balance: balance != nil ? TokenInt(balance!)! : nil)
        return account
    }

}
