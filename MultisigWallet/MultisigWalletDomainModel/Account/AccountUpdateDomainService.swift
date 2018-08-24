//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

public class AccountsBalancesUpdated: DomainEvent {}

open class AccountUpdateDomainService {

    public init() {}

    open func updateAccountsBalances() {
        precondition(!Thread.isMainThread)
        addMissingAccountsForWhitelistedTokenItems()
        updateBalancesForWhitelistedAccounts()
        DomainRegistry.eventPublisher.publish(AccountsBalancesUpdated())
    }

    private func addMissingAccountsForWhitelistedTokenItems() {
        guard let wallet = DomainRegistry.walletRepository.selectedWallet() else { return }
        let allWalletAccountsTokensIds = allSelectedWalletAccountsIds().map { $0.tokenID }
        let whitelistedIds = whitelisteItemsTokensIds()
        let missingAccountsTokensIds = Set(whitelistedIds).subtracting(Set(allWalletAccountsTokensIds))
        missingAccountsTokensIds.forEach { tokenID in
            let account = Account(tokenID: tokenID, walletID: wallet.id)
            DomainRegistry.accountRepository.save(account)
        }
    }

    private func updateBalancesForWhitelistedAccounts() {
        let allWalletAccountsIds = allSelectedWalletAccountsIds()
        let whitelistedIds = whitelisteItemsTokensIds()
        let whitelistedAccountsIds = allWalletAccountsIds.filter {
            whitelistedIds.index(of: $0.tokenID) != nil
        }
        updateAccountsBalances(whitelistedAccountsIds)
    }

    private func updateAccountsBalances(_ accountIDs: [AccountID]) {
        accountIDs.forEach { accountID in
            let account = DomainRegistry.accountRepository.find(id: accountID, walletID: accountID.walletID)!
            if account.balance == nil {
                account.add(amount: TokenInt(arc4random_uniform(UInt32.max)))
                DomainRegistry.accountRepository.save(account)
            }
        }
    }

    private func whitelisteItemsTokensIds() -> [TokenID] {
        return DomainRegistry.tokenListItemRepository.whitelisted().map { $0.id }
    }

    private func allSelectedWalletAccountsIds() -> [AccountID] {
        guard let wallet = DomainRegistry.walletRepository.selectedWallet() else { return [] }
        return DomainRegistry.accountRepository.all()
            .filter { $0.walletID == wallet.id }
            .map { $0.id }
    }

}
