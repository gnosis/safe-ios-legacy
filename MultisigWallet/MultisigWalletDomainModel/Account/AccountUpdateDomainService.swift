//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

open class AccountUpdateDomainService {

    public init() {}

    // TODO: Should be done once a wallet is created.
    open func updateAccountsBalances() {
        precondition(!Thread.isMainThread)
        addMissingAccountsForWhitelistedTokenItems()

    }

    open func updateAccountBalance(accountID: AccountID) {
        precondition(!Thread.isMainThread)
    }

    private func addMissingAccountsForWhitelistedTokenItems() {
        guard let wallet = DomainRegistry.walletRepository.selectedWallet() else { return }
        let allAccountIds = DomainRegistry.accountRepository.all().map { $0.id.id }
        let whitelistedItemsIds = DomainRegistry.tokenListItemRepository.all().filter {
            $0.status == .whitelisted }.map { $0.id.id }
        let missingAccountsIds = Set(whitelistedItemsIds).subtracting(Set(allAccountIds))
        missingAccountsIds.forEach { strId in
            let account = Account(id: AccountID(strId), walletID: wallet.id, balance: nil)
            DomainRegistry.accountRepository.save(account)
        }
    }

}
