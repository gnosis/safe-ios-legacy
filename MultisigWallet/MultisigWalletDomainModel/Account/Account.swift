//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

/// Identifier of a wallet token account.
public struct AccountID: Hashable {

    /// Token code, for example, "ETH"
    public internal(set) var token: String

    /// Creates new account ID with token code
    ///
    /// - Parameter token: token code, like "ETH"
    public init(token: String) {
        self.token = token
    }

}

/// Represents account balance for a token type. Account belongs to a wallet, which is referenced by WaleltID
public class Account: IdentifiableEntity<AccountID> {

    /// Token balance, in smallest token units.
    public private(set) var balance: TokenInt
    /// Wallet to which this account belongs to.
    public let walletID: WalletID
    /// Utility requirement for a wallet account. Required minimum amount needed for wallet deployment.
    public private(set) var minimumDeploymentTransactionAmount: TokenInt

    /// Creates new account with specified arguments.
    ///
    /// - Parameters:
    ///   - id: account identifier
    ///   - walletID: wallet identifier
    ///   - balance: balance of the account, in smallest token units
    ///   - minimumAmount: minimum required amount for wallet deployment transaction
    public init(id: AccountID, walletID: WalletID, balance: TokenInt, minimumAmount: TokenInt) {
        self.balance = balance
        self.walletID = walletID
        self.minimumDeploymentTransactionAmount = minimumAmount
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

    /// Update minimum deployment amount to a new value
    ///
    /// - Parameter newValue: new value for minimum amount
    public func updateMinimumTransactionAmount(_ newValue: TokenInt) {
        minimumDeploymentTransactionAmount = newValue
    }

}
