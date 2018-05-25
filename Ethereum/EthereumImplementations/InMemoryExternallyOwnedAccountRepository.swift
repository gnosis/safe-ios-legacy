//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumDomainModel

public class InMemoryExternallyOwnedAccountRepository: ExternallyOwnedAccountRepository {

    private var accounts = [Address: ExternallyOwnedAccount]()

    public init () {}

    public func save(_ account: ExternallyOwnedAccount) throws {
        accounts[account.address] = account
    }

    public func remove(_ account: ExternallyOwnedAccount) throws {
        accounts.removeValue(forKey: account.address)
    }

    public func find(by address: Address) throws -> ExternallyOwnedAccount? {
        return accounts[address]
    }

}
