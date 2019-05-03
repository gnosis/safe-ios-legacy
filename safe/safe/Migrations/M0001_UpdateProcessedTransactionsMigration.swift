//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import CommonImplementations
import MultisigWalletImplementations
import Database

final class M0001_UpdateProcessedTransactionsMigration: Migration {

    convenience init() {
        // DO NOT CHANGE!
        self.init("0001_UpdateProcessedTransactionsMigration")
    }

    override func setUp(connection: Connection) throws {
        try SynchronisationService.syncProcessedTransactions()
    }

}
