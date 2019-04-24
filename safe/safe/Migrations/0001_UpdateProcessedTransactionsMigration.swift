//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import CommonImplementations
import MultisigWalletImplementations
import Database

class UpdateProcessedTransactionsMigration: Migration {

    convenience init() {
        // DO NOT CHANGE!
        self.init("0001_UpdateProcessedTransactionsMigration")
    }

    required init(_ id: String) {
        super.init(id)
    }

    override func setUp(connection: Connection) throws {
        try SynchronisationService.syncProcessedTransactions()
    }

}
