//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

public class InMemoryAccountRepository: AccountRepository {

    private struct ID: Hashable {
        var accountID: AccountID
        var walletID: WalletID
    }

    private var accounts = [ID: Account]()

    public init() {}

    public func save(_ account: Account) throws {
        accounts[id(of: account)] = account
    }

    private func id(of account: Account) -> ID {
        return ID(accountID: account.id, walletID: account.walletID)
    }

    public func remove(_ account: Account) throws {
        accounts.removeValue(forKey: id(of: account))
    }

    public func find(id: AccountID, walletID: WalletID) throws -> Account? {
        return accounts[ID(accountID: id, walletID: walletID)]
    }

}
