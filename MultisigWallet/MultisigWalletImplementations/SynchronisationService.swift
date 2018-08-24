//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

import Foundation
import MultisigWalletDomainModel

public final class SynchronisationService: SynchronisationDomainService {

    private let retryInterval: TimeInterval
    private let merger: TokenListMerger
    private let accountService: AccountUpdateDomainService

    public init(retryInterval: TimeInterval,
                merger: TokenListMerger = TokenListMerger(),
                accountService: AccountUpdateDomainService = AccountUpdateDomainService()) {
        self.retryInterval = retryInterval
        self.merger = merger
        self.accountService = accountService
    }

    /// Synchronise stored data with info from services.
    /// Should be called from a background thread.
    public func sync() {
        precondition(!Thread.isMainThread)
        syncTokenList()
        syncAccounts()
    }

    private func syncTokenList() {
        try! RetryWithIncreasingDelay(maxAttempts: Int.max, startDelay: retryInterval) { [weak self] _ in
            let tokenList = try DomainRegistry.tokenListService.items()
            self?.merger.mergeStoredTokenItems(with: tokenList)
        }.start()
    }

    private func syncAccounts() {
        try! RetryWithIncreasingDelay(maxAttempts: Int.max, startDelay: retryInterval) { [weak self] _ in
            self?.accountService.updateAccountsBalances()
        }.start()
    }

}
