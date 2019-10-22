//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

/// In-memory implementation of account repository, used for testing purposes.
public class InMemoryAccountRepository: AccountRepository {

    private var accounts = [AccountID: Account]()

    public init() {}

    public func save(_ account: Account) {
        accounts[account.id] = account
    }

    public func remove(_ account: Account) {
        accounts.removeValue(forKey: account.id)
    }

    public func find(id: AccountID) -> Account? {
        return accounts[id]
    }

    public func all() -> [Account] {
        return Array(accounts.values)
    }

    public func filter(walletID: WalletID) -> [Account] {
        return all().filter { $0.id.walletID == walletID }
    }

}
