//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Database
import CommonImplementations

final class M0004_AddColumnsToWallet: Migration {

    convenience init() {
        // DO NOT CHANGE!
        self.init("M0004_AddColumnsToWallet")
    }

    override func setUp(connection: Connection) throws {
        let addMasterCopySQL = "ALTER TABLE tbl_wallets ADD master_copy_address TEXT;"
        try connection.execute(sql: addMasterCopySQL)
        let addVersionSQL = "ALTER TABLE tbl_wallets ADD contract_version TEXT;"
        try connection.execute(sql: addVersionSQL)
    }

}
