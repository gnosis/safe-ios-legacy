//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

struct WalletMigrations {

    static let all = [
//        M0001_UpdateProcessedTransactionsMigration(), // this needs to be a startup backgroud task and not a migration
        M0002_AddFeeTokenToWallet(),
        M0003_AddCanPayTransactionFeeToTokenListItem(),
        M0004_AddColumnsToWallet(),
        M0005_ChangeTransactionFeeColumnType(),
        M0006_RemoveWalletIDFromTransactions()
    ]

    static let latest = all.last!

}
