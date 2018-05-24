//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumDomainModel
import Database

public class DBExternallyOwnedAccountRepository: ExternallyOwnedAccountRepository {

    private let db: Database

    public init (db: Database) {
        self.db = db
    }

    public func save(_ account: ExternallyOwnedAccount) throws {

    }

    public func remove(_ account: ExternallyOwnedAccount) throws {

    }

    public func find(by address: Address) throws -> ExternallyOwnedAccount? {
        return nil
    }

}
