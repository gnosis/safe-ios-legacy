//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

open class AccountUpdateDomainService {

    public init() {}

    // TODO: Should be done once a wallet is created.
    open func updateAccountsBalances() {
        precondition(!Thread.isMainThread)
        addMissingAccountsForWhitelistedTokenItems()
        updateBalancesForWhitelistedAccounts()
    }

    private func addMissingAccountsForWhitelistedTokenItems() {
        guard let wallet = DomainRegistry.walletRepository.selectedWallet() else { return }
        let allWalletAccountsIds = DomainRegistry.accountRepository.all()
            .filter { $0.walletID == wallet.id }
            .map { $0.id.tokenID.id }
        let whitelistedItemsIds = DomainRegistry.tokenListItemRepository.all().filter {
            $0.status == .whitelisted }.map { $0.id.id }
        let missingAccountsIds = Set(whitelistedItemsIds).subtracting(Set(allWalletAccountsIds))
        missingAccountsIds.forEach { strId in
            let account = Account(tokenID: TokenID(strId), walletID: wallet.id)
            DomainRegistry.accountRepository.save(account)
        }
    }

    private func updateBalancesForWhitelistedAccounts() {
        guard let wallet = DomainRegistry.walletRepository.selectedWallet() else { return }
        let allWalletAccountsIds = DomainRegistry.accountRepository.all()
            .filter { $0.walletID == wallet.id }
            .map { $0.id }
        let whitelistedItemsTokensIds = DomainRegistry.tokenListItemRepository.all().filter {
            $0.status == .whitelisted }.map { $0.id }
        let whitelistedAccountsIds = allWalletAccountsIds.filter {
            whitelistedItemsTokensIds.index(of: $0.tokenID) != nil
        }
        updateAccountsBalances(whitelistedAccountsIds)
    }

    // TODO: add real implementation
    private func updateAccountsBalances(_ accountIDs: [AccountID]) {
        accountIDs.forEach { id in
            let account = DomainRegistry.accountRepository.find(id: id, walletID: id.walletID)!
            if account.balance == nil {
                account.add(amount: TokenInt(arc4random_uniform(100)))
                DomainRegistry.accountRepository.save(account)
            }
        }
    }

}
