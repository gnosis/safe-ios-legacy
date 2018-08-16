//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

/// Identifier of a wallet token account.
public class AccountID: BaseID {}

/// Represents account balance for a token type. Account belongs to a wallet, which is referenced by WaleltID
public class Account: IdentifiableEntity<AccountID> {

    /// Token balance, in smallest token units.
    public private(set) var balance: TokenInt
    /// Wallet to which this account belongs to.
    public let walletID: WalletID

    /// Creates new account with specified arguments.
    ///
    /// - Parameters:
    ///   - id: account identifier
    ///   - walletID: wallet identifier
    ///   - balance: balance of the account, in smallest token units
    public init(id: AccountID, walletID: WalletID, balance: TokenInt) {
        self.balance = balance
        self.walletID = walletID
        super.init(id: id)
    }

    /// Updates balance to a new value
    ///
    /// - Parameter newAmount: new amount value
    public func update(newAmount: TokenInt) {
        balance = newAmount
    }

    /// Increases balance by the amount
    ///
    /// - Parameter amount: amount to add to balance
    public func add(amount: TokenInt) {
        balance += amount
    }

    /// Decreases balance by the amount
    ///
    /// - Parameter amount: amount to subtract from balance
    public func withdraw(amount: TokenInt) {
        balance -= amount
    }

}
