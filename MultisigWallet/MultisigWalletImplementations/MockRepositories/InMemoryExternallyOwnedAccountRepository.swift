//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

public class InMemoryExternallyOwnedAccountRepository: ExternallyOwnedAccountRepository {

    private var accounts = [Address: ExternallyOwnedAccount]()

    public init () {}

    public func save(_ account: ExternallyOwnedAccount) {
        accounts[account.address] = account
    }

    public func remove(address: Address) {
        accounts.removeValue(forKey: address)
    }

    public func find(by address: Address) -> ExternallyOwnedAccount? {
        return accounts[address]
    }

}
