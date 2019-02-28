//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

public class AccountsBalancesUpdated: DomainEvent {}

open class AccountUpdateDomainService {

    public init() {}

    public func updateAccountBalance(token: Token) throws {
        precondition(!Thread.isMainThread)
        guard let wallet = DomainRegistry.walletRepository.selectedWallet() else { return }
        let accountID = AccountID(tokenID: token.id, walletID: wallet.id)
        if DomainRegistry.accountRepository.find(id: accountID) == nil {
            let account = Account(tokenID: token.id, walletID: wallet.id)
            DomainRegistry.accountRepository.save(account)
        }
        try updateAccountsBalances([accountID])
        DomainRegistry.eventPublisher.publish(AccountsBalancesUpdated())
    }

    open func updateAccountsBalances() throws {
        precondition(!Thread.isMainThread)
        addMissingAccountsForWhitelistedTokenItems()
        try updateBalancesForWhitelistedAccounts()
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

    private func updateBalancesForWhitelistedAccounts() throws {
        let allWalletAccountsIds = allSelectedWalletAccountsIds()
        let whitelistedIds = whitelisteItemsTokensIds()
        let whitelistedAccountsIds = allWalletAccountsIds.filter {
            $0.tokenID == Token.Ether.id || whitelistedIds.index(of: $0.tokenID) != nil
        }
        try updateAccountsBalances(whitelistedAccountsIds)
    }

    private func updateAccountsBalances(_ accountIDs: [AccountID]) throws {
        try accountIDs.forEach { accountID in
            guard let balance = try self.balance(of: accountID) else { return }
            let account = DomainRegistry.accountRepository.find(id: accountID)!
            account.update(newAmount: balance)
            DomainRegistry.accountRepository.save(account)
        }
    }

    private func balance(of accountID: AccountID) throws -> TokenInt? {
        guard let wallet = DomainRegistry.walletRepository.find(id: accountID.walletID),
            let address = wallet.address else { return nil }
        if accountID.tokenID == Token.Ether.id {
            return try DomainRegistry.ethereumNodeService.eth_getBalance(account: address)
        } else {
            let token = DomainRegistry.tokenListItemRepository.find(id: accountID.tokenID)!
            let proxy = ERC20TokenContractProxy(token.token.address)
            return try proxy.balance(of: address)
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
