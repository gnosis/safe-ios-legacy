//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

/// Represents collection of all accounts
public protocol AccountRepository {

    /// Persists account
    ///
    /// - Parameter account: account to save
    func save(_ account: Account)

    /// Removes account
    ///
    /// - Parameter account: account to remove
    func remove(_ account: Account)

    /// Searches for account by id and wallet identifier.
    ///
    /// - Parameters:
    ///   - id: account identifier
    ///   - walletID: wallet identifier
    /// - Returns: account if found, or nil otherwise.
    func find(id: AccountID, walletID: WalletID) -> Account?

    /// Return all accounts
    ///
    /// - Returns: all accounts
    func all() -> [Account]

}
