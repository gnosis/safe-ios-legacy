//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public struct AccountID: Hashable {

    public internal(set) var token: String

    public init(token: String) {
        self.token = token
    }

}

public class Account: IdentifiableEntity<AccountID> {

    public private(set) var balance: TokenInt
    public let walletID: WalletID
    public private(set) var minimumDeploymentTransactionAmount: TokenInt

    public init(id: AccountID, walletID: WalletID, balance: TokenInt, minimumAmount: TokenInt) {
        self.balance = balance
        self.walletID = walletID
        self.minimumDeploymentTransactionAmount = minimumAmount
        super.init(id: id)
    }

    public func update(newAmount: TokenInt) {
        balance = newAmount
    }

    public func add(amount: TokenInt) {
        balance += amount
    }

    public func withdraw(amount: TokenInt) {
        balance -= amount
    }

    public func updateMinimumTransactionAmount(_ newValue: TokenInt) {
        minimumDeploymentTransactionAmount = newValue
    }

}
