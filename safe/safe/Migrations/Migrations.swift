//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

struct WalletMigrations {

    static let all = [
        M0001_UpdateProcessedTransactionsMigration(),
        M0002_AddFeeTokenToWallet(),
        M0003_AddCanPayTransactionFeeToTokenListItem(),
        M0004_AddColumnsToWallet()
    ]

    static let latest = all.last!

}
