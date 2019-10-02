//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

/// Identifier of a wallet token account.
public class AccountID: BaseID {

    private static let idSeparator: Character = ":"

    public required init(_ id: String) {
        precondition(id.split(separator: AccountID.idSeparator).count == 2, "Wrong format of AccountID")
        super.init(id)
    }

    public init(tokenID: TokenID, walletID: WalletID) {
        precondition(!walletID.id.isEmpty)
        precondition(!tokenID.id.isEmpty)
        super.init("\(tokenID.id)\(AccountID.idSeparator)\(walletID.id)")
    }

    public var walletID: WalletID {
        let walletID = String(id.split(separator: AccountID.idSeparator)[1])
        return WalletID(walletID)
    }

    public var tokenID: TokenID {
        let walletID = String(id.split(separator: AccountID.idSeparator)[0])
        return TokenID(walletID)
    }

}

/// Represents account balance for a token type. Account belongs to a wallet, which is referenced by WaleltID
public class Account: IdentifiableEntity<AccountID> {

    /// Token balance, in smallest token units.
    public private(set) var balance: TokenInt?
    /// Wallet to which this account belongs to.
    public var walletID: WalletID { return id.walletID }

    /// Creates new account with specified arguments.
    ///
    /// - Parameters:
    ///   - tokenID: account token identifier
    ///   - walletID: wallet identifier
    ///   - balance: balance of the account, in smallest token units
    public init(tokenID: TokenID, walletID: WalletID, balance: TokenInt? = nil) {
        self.balance = balance
        super.init(id: AccountID(tokenID: tokenID, walletID: walletID))
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
        if balance == nil { balance = 0 }
        balance! += amount
    }

    /// Decreases balance by the amount
    ///
    /// - Parameter amount: amount to subtract from balance
    public func withdraw(amount: TokenInt) {
        precondition(balance != nil && balance! >= amount)
        balance! -= amount
    }

    /// Compare an account against other account. Accounts are equal when all properties are the same.
    ///
    /// - Parameter to: Account to compare with
    /// - Returns: comparison result
    public func isEqual(to: Account) -> Bool {
        return id == to.id &&
            balance == to.balance &&
            walletID == to.walletID
    }

}
