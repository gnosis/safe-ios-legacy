//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Database
import CommonImplementations

final class M0008_AddWalletNameField: Migration {

    convenience init() {
        // DO NOT CHANGE
        self.init("M0008_AddWalletNameField")
    }

    override func setUp(connection: Connection) throws {
        let addNameSQL = "ALTER TABLE tbl_wallets ADD name TEXT DEFAULT 'Safe';"
        try connection.execute(sql: addNameSQL)
    }

}
