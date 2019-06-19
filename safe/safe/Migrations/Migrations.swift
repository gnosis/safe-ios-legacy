//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

struct WalletMigrations {

    // IMPORTANT! In migrations, use only SQL and not application code. Application code must be in sync with the
    // database schema at the point of migration or not executed at all.
    static let all = [
        // Counter starting from M0002 because M0001 transaction was invalid and had to be deleted.
        M0002_AddFeeTokenToWallet(),
        M0003_AddCanPayTransactionFeeToTokenListItem(),
        M0004_AddColumnsToWallet(),
        M0005_ChangeTransactionFeeColumnType(),
        M0006_RemoveWalletIDFromTransactions()
    ]

    static let latest = all.last!

}
