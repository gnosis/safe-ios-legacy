//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common
import MultisigWalletDomainModel
import Database

public class DBWalletRepository: WalletRepository, Assertable {

    struct SQL {
        static let createTable = """
CREATE TABLE IF NOT EXISTS tbl_wallet (
    wallet_id TEXT NOT NULL PRIMARY KEY,
    data BLOB NOT NULL
);
"""
        static let insertWallet = "INSERT OR REPLACE INTO tbl_wallet VALUES (?, ?);"
        static let deleteWallet = "DELETE FROM tbl_wallet WHERE wallet_id = ?;"
        static let findByID = "SELECT wallet_id, data FROM tbl_wallet WHERE wallet_id = ? LIMIT 1;"
    }

    public enum Error: String, LocalizedError, Hashable {
        case invalidWalletStoredWithData
    }

    private let db: Database

    public init(db: Database) {
        self.db = db
    }

    public func setUp() throws {
        try db.execute(sql: SQL.createTable)
    }

    public func save(_ wallet: Wallet) throws {
        try db.execute(sql: SQL.insertWallet, bindings: [wallet.id.id, try wallet.data()])
    }

    public func remove(_ walletID: WalletID) throws {
        try db.execute(sql: SQL.deleteWallet, bindings: [walletID.id])
    }

    public func findByID(_ walletID: WalletID) throws -> Wallet? {
        guard let result = try? db.execute(sql: SQL.findByID,
                                           bindings: [walletID.id],
                                           resultMap: walletFromResultSet).first as? Wallet else { return nil }
        return result
    }

    private func walletFromResultSet(_ rs: ResultSet) throws -> Wallet? {
        guard let id = rs.string(at: 0), let data = rs.data(at: 1) else {
            return nil
        }
        let wallet = try Wallet(data: data)
        try assertEqual(wallet.id, try WalletID(id), Error.invalidWalletStoredWithData)
        return wallet
    }

    public func nextID() -> WalletID {
        return try! WalletID()
    }
}
