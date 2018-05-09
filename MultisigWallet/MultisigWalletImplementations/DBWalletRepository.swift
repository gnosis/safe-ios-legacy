//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import Database

public class DBWalletRepository: WalletRepository {

    struct SQL {
    }

    private let db: Database

    public init(db: Database) {
        self.db = db
    }

    public func setUp() throws {
    }

    public func save(_ wallet: Wallet) throws {

    }

    public func remove(_ walletID: WalletID) throws {

    }

    public func findByID(_ walletID: WalletID) throws -> Wallet? {
        return nil
    }

}
