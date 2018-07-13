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
    token TEXT NOT NULL,
    wallet_id TEXT NOT NULL,
    balance INTEGER NOT NULL,
    minimum INTEGER NOT NULL,
    PRIMARY KEY (token, wallet_id)
);
"""
        static let insert = "INSERT OR REPLACE INTO tbl_accounts VALUES (?, ?, ?, ?);"
        static let delete = "DELETE FROM tbl_accounts WHERE token = ? AND wallet_id = ?;"
        static let find = """
SELECT token, wallet_id, balance, minimum
FROM tbl_accounts
WHERE token = ? AND wallet_id = ? LIMIT 1;
"""
    }

    private let db: Database

    public init(db: Database) {
        self.db = db
    }

    public func setUp() {
        try! db.execute(sql: SQL.createTable)
    }

    public func save(_ account: Account) {
        try! db.execute(sql: SQL.insert, bindings: [account.id.token,
                                                    account.walletID.id,
                                                    account.balance,
                                                    account.minimumDeploymentTransactionAmount])
    }

    public func remove(_ account: Account) {
        try! db.execute(sql: SQL.delete, bindings: [account.id.token,
                                                    account.walletID.id])
    }

    public func find(id: AccountID, walletID: WalletID) -> Account? {
        return try! db.execute(sql: SQL.find,
                               bindings: [id.token, walletID.id],
                               resultMap: accountFromResultSet).first as? Account
    }

    private func accountFromResultSet(_ rs: ResultSet) -> Account? {
        guard let token = rs.string(at: 0),
            let walletID = rs.string(at: 1),
            let balance = rs.int(at: 2),
            let minimum = rs.int(at: 3) else {
                return nil
        }
        let account = Account(id: AccountID(token: token),
                              walletID: WalletID(walletID),
                              balance: balance,
                              minimumAmount: minimum)
        return account
    }

}
