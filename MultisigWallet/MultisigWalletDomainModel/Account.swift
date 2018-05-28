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

    public private(set) var balance: Int
    public let walletID: WalletID
    public private(set) var minimumDeploymentTransactionAmount: Int

    public init(id: AccountID, walletID: WalletID, balance: Int, minimumAmount: Int) {
        self.balance = balance
        self.walletID = walletID
        self.minimumDeploymentTransactionAmount = minimumAmount
        super.init(id: id)
    }

    public func update(newAmount: Int) {
        balance = newAmount
    }

    public func add(amount: Int) {
        balance += amount // overflow!
    }

    public func withdraw(amount: Int) {
        balance -= amount
    }

    public func updateMinimumTransactionAmount(_ newValue: Int) {
        minimumDeploymentTransactionAmount = newValue
    }

}
