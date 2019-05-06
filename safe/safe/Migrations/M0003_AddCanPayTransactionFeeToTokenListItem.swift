//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import CommonImplementations
import Database

import MultisigWalletApplication

final class M0003_AddCanPayTransactionFeeToTokenListItem: Migration {

    convenience init() {
        // DO NOT CHANGE!
        self.init("M0003_AddCanPayTransactionFeeToTokenListItem")
    }

    override func setUp(connection: Connection) throws {
        let sql = "ALTER TABLE tbl_token_list_items ADD can_pay_transaction_fee BOOLEAN DEFAULT 0;"
        try connection.execute(sql: sql)
    }

}
