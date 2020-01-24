//
//  Copyright © 2020 Gnosis Ltd. All rights reserved.
//

import Foundation
import Database
import CommonImplementations

final class M0010_AddWalletTypeField: Migration {

    convenience init() {
        // DO NOT CHANGE
        self.init("M0010_AddWalletTypeField")
    }

    override func setUp(connection: Connection) throws {
        let addNameSQL = "ALTER TABLE tbl_wallets ADD type INTEGER NOT NULL DEFAULT 0;"
        try connection.execute(sql: addNameSQL)
    }

}
