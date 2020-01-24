//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public protocol SynchronisationDomainService {

    /// When App restarts we should reconnect to stored WalletConnect sessions
    /// to get messages from dApps.
    func syncWalletConnectSessions()

    /// Request available tokens and account balances once.
    func syncTokensAndAccountsOnce()

    func syncTransactionsOnce()

    /// Update periodically account balances, pending transactions.
    /// Make post-processing for transactions.
    func startSyncLoop()

    /// Stop periodic updates.
    func stopSyncLoop()

}
