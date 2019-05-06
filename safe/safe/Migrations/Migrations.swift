//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

struct WalletMigrations {

    static let all = [
        M0001_UpdateProcessedTransactionsMigration()
    ]

    static let latest = all.last!

}
