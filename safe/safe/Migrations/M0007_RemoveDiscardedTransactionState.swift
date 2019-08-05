//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Database
import CommonImplementations


final class M0007_RemoveDiscardedTransactionState: Migration {

    convenience init() {
        // DO NOT CHANGE
        self.init("M0007_RemoveDiscurdedTransactionState")
    }

    override func setUp(connection: Connection) throws {
        let deleteSQL = "DELETE FROM tbl_transactions WHERE transaction_status = 6;"
        try connection.execute(sql: deleteSQL)
    }

}
