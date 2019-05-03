//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import CommonImplementations
import Database

final class M0002_AddFeeTokenToWallet: Migration {

    convenience init() {
        // DO NOT CHANGE!
        self.init("M0002_AddFeeTokenToWallet")
    }

//    required init(_ id: String) {
//        super.init(id)
//    }

    override func setUp(connection: Connection) throws {
        let sql = "ALTER TABLE tbl_wallets ADD fee_payment_token_address TEXT;"
        try connection.execute(sql: sql)
    }

}
